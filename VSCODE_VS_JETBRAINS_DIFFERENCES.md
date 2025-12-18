# 🆚 Différences VS Code vs JetBrains - Architecture VaultAI

## 🏗️ Architecture Générale

### VS Code

```
┌─────────────────────────────────────────┐
│        Extension Host (Node.js)         │
│  ┌───────────────────────────────────┐  │
│  │  TypeScript Extension Code        │  │
│  │  - commands.ts                    │  │
│  │  - VsCodeExtension.ts             │  │
│  └───────────┬───────────────────────┘  │
│              │                           │
│              ↓                           │
│  ┌───────────────────────────────────┐  │
│  │  Webview (HTML/JS/React)          │  │
│  │  - vscode.postMessage()           │  │
│  │  - window.addEventListener()      │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### JetBrains

```
┌─────────────────────────────────────────┐
│      IntelliJ Platform (JVM/Kotlin)     │
│  ┌───────────────────────────────────┐  │
│  │  Kotlin Plugin Code               │  │
│  │  - ContinuePluginActions.kt       │  │
│  │  - IdeProtocolClient.kt           │  │
│  └───────────┬───────────────────────┘  │
│              │                           │
│              ↓                           │
│  ┌───────────────────────────────────┐  │
│  │  JCEF Webview (Chromium)          │  │
│  │  - window.postIntellijMessage()   │  │
│  │  - window.postMessage()           │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 📡 Communication IDE ↔ GUI

### VS Code : Bidirectionnelle Simple

**GUI → Extension** :

```typescript
// gui/src/context/IdeMessenger.tsx
vscode.postMessage({
  messageType: "showFile",
  data: { filepath: "/path/to/file" },
  messageId: "abc123",
});
```

**Extension → GUI** :

```typescript
// extensions/vscode/src/commands.ts
webviewProtocol.request("navigateTo", {
  path: "/config",
  toggle: true,
});
```

**Réception dans GUI** :

```typescript
// gui/src/hooks/useWebviewListener.ts
window.addEventListener("message", (event) => {
  if (event.data.messageType === "navigateTo") {
    navigate(event.data.data.path);
  }
});
```

✅ **Avantage VS Code** : API native `vscode.postMessage()` très fiable et bien documentée.

### JetBrains : Deux Couches de Communication

**GUI → Plugin** :

```typescript
// gui/src/context/IdeMessenger.tsx
window.postIntellijMessage("showFile", { filepath: "/path/to/file" }, "abc123");
```

**Plugin → GUI** :

```kotlin
// extensions/intellij/.../browser/ContinueBrowser.kt
val json = Gson().toJson(BrowserMessage(messageType, messageId, data))
val jsCode = """window.postMessage($json, "*");"""
browser.executeJavaScriptAsync(jsCode)
```

**Réception dans GUI** (même que VS Code) :

```typescript
window.addEventListener("message", (event) => {
  if (event.data.messageType === "navigateTo") {
    navigate(event.data.data.path);
  }
});
```

⚠️ **Difficulté JetBrains** :

1. `window.postIntellijMessage` doit être injecté manuellement via JavaScript
2. JCEF peut avoir des problèmes de timing (page pas encore chargée)
3. `executeJavaScriptAsync()` peut échouer silencieusement

## 🎯 Bouton "Configure" : Pourquoi ça Fonctionne sur VS Code

### Sur VS Code

1. **Clic sur bouton** (GUI React)

   ```typescript
   // Quelque part dans le GUI
   <button onClick={() => {
     ideMessenger.request("config/openProfile", { profileId: "..." });
   }}>
     Configure
   </button>
   ```

2. **Message envoyé à l'extension**

   ```typescript
   vscode.postMessage({
     messageType: "config/openProfile",
     data: { profileId: "..." },
   });
   ```

3. **Extension reçoit et ouvre le fichier**
   ```typescript
   // extensions/vscode/src/VsCodeIdeProtocol.ts
   case "config/openProfile":
     const configPath = getConfigYamlPath();
     const doc = await vscode.workspace.openTextDocument(configPath);
     await vscode.window.showTextDocument(doc);
   ```

✅ **Résultat** : Le fichier `config.yaml` s'ouvre dans l'éditeur VS Code.

### Sur JetBrains (Théorique)

1. **Clic sur bouton toolbar** (icône engrenage dans JetBrains)

   ```kotlin
   // ContinuePluginActions.kt
   class OpenConfigAction : ContinueToolbarAction() {
       override fun toolbarActionPerformed(project: Project) {
           project.getBrowser()?.sendToWebview(
               "navigateTo",
               mapOf("path" to "/config", "toggle" to true)
           )
       }
   }
   ```

2. **Message envoyé au GUI**

   ```kotlin
   // ContinueBrowser.kt
   val jsCode = """window.postMessage({
     messageType: "navigateTo",
     data: { path: "/config", toggle: true }
   }, "*");"""
   browser.executeJavaScriptAsync(jsCode)
   ```

3. **GUI React reçoit le message**

   ```typescript
   // gui/src/components/Layout.tsx
   useWebviewListener("navigateTo", async (data) => {
     navigate(data.path); // → Navigue vers /config
   });
   ```

4. **Page config affichée, puis ouverture du fichier**

   À CE MOMENT, il devrait y avoir un bouton "Open config.yaml" dans la page config, qui appelle :

   ```typescript
   ideMessenger.request("config/openProfile", { ... });
   ```

❓ **Problème Possible** : Sur JetBrains, peut-être que :

- Le message `navigateTo` n'arrive jamais au GUI
- Ou alors la page `/config` s'affiche mais il n'y a pas de bouton pour ouvrir le fichier
- Ou le bouton existe mais appelle une méthode qui ne fonctionne pas sur JetBrains

## 🔍 Différences Clés dans l'Ouverture de Fichiers

### VS Code

```typescript
// extensions/vscode/src/VsCodeIde.ts
async openFile(path: string) {
  const uri = vscode.Uri.file(path);
  const doc = await vscode.workspace.openTextDocument(uri);
  await vscode.window.showTextDocument(doc);
}
```

✅ Simple, API native, toujours fonctionne.

### JetBrains

```kotlin
// extensions/intellij/.../continue/IntelliJIDE.kt
override fun openFile(filepath: String) {
    ApplicationManager.getApplication().invokeLater {
        val virtualFile = VirtualFileManager.getInstance()
            .findFileByUrl("file://$filepath")

        if (virtualFile != null) {
            FileEditorManager.getInstance(project)
                .openFile(virtualFile, true)
        }
    }
}
```

⚠️ **Problèmes possibles** :

1. **Chemin incorrect** : Le format `file://` peut ne pas fonctionner sur Windows (`file:///C:/...`)
2. **VirtualFile null** : Si le fichier n'est pas dans le Virtual File System de JetBrains
3. **Permissions** : Le fichier `~/.continue/config.yaml` est en dehors du projet
4. **Thread UI** : `invokeLater` peut échouer si appelé au mauvais moment

## 🐛 Hypothèses sur les Bugs JetBrains

### Bug 1 : Bouton "Configure" Ne Fait Rien

**Hypothèse A** : Le bouton toolbar JetBrains appelle `OpenConfigAction`, qui envoie `navigateTo` au GUI, mais :

- Soit le message n'arrive jamais (problème JCEF)
- Soit le GUI ne reçoit pas le message (`window.addEventListener` pas enregistré)
- Soit le message arrive mais la navigation React ne fonctionne pas

**Test** :

```javascript
// Dans DevTools du webview
window.addEventListener("message", (e) => {
  console.log("📨 Message received:", e.data);
});
```

Puis cliquer sur le bouton "Configure" et voir si un log apparaît.

**Hypothèse B** : Il n'y a PAS de bouton "Configure" dans le toolbar JetBrains, contrairement à VS Code.

**Test** : Regarder si l'icône d'engrenage existe dans la toolbar JetBrains.

### Bug 2 : Chat Tourne dans le Vide

**Hypothèse A** : Le Core Process (serveur Node.js) n'est pas démarré.

**Test** :

```bash
ps aux | grep continue
tail -f ~/.continue/logs/core.log
```

**Hypothèse B** : Le message du chat est envoyé au Core mais la réponse ne revient jamais.

**Test** : Regarder dans `core.log` si le message `llm/streamChat` arrive.

**Hypothèse C** : La communication GUI ↔ Plugin est cassée (même problème que bouton Configure).

**Test** : Envoyer un message simple depuis DevTools :

```javascript
window.postIntellijMessage("getIdeInfo", {}, "test-123");
```

Et voir si une réponse arrive.

## 🛠️ Correctifs Proposés

### Fix 1 : Ajouter un Bouton "Open config.yaml" dans le GUI

Dans la page config JetBrains, ajouter un bouton explicite :

```typescript
// gui/src/pages/config/index.tsx
import { useContext } from "react";
import { IdeMessengerContext } from "../../context/IdeMessenger";

function ConfigPage() {
  const ideMessenger = useContext(IdeMessengerContext);

  const openConfigFile = async () => {
    const ideInfo = await ideMessenger.request("getIdeInfo", undefined);
    if (ideInfo.ideType === "jetbrains") {
      // JetBrains : ouvrir via showFile
      await ideMessenger.request("showFile", {
        filepath: "~/.continue/config.yaml" // ou chemin absolu
      });
    } else {
      // VS Code : utiliser la commande native
      await ideMessenger.request("config/openProfile", {});
    }
  };

  return (
    <div>
      <button onClick={openConfigFile}>
        📝 Open config.yaml
      </button>
      {/* reste de la page */}
    </div>
  );
}
```

### Fix 2 : Vérifier que `window.postIntellijMessage` Existe

Dans `ContinueBrowser.kt`, ajouter une vérification :

```kotlin
private fun executeJavaScript(myJSQueryOpenInBrowser: JBCefJSQuery) {
    val script = """
        window.postIntellijMessage = function(messageType, data, messageId) {
            const msg = JSON.stringify({messageType, data, messageId});
            ${myJSQueryOpenInBrowser.inject("msg")}
        }

        // VAULTAI DEBUG: Vérifier que la fonction existe
        console.log("✅ VAULTAI: postIntellijMessage injected successfully");
        console.log("Function exists:", typeof window.postIntellijMessage);
    """
    browser.cefBrowser.executeJavaScript(script, getGuiUrl(), 0)
}
```

### Fix 3 : Gérer le Chemin Windows Correctement

Dans `IntelliJIDE.kt` :

```kotlin
override fun openFile(filepath: String) {
    ApplicationManager.getApplication().invokeLater {
        // Expand ~ to home directory
        val expandedPath = if (filepath.startsWith("~")) {
            System.getProperty("user.home") + filepath.substring(1)
        } else {
            filepath
        }

        // Convert to proper file:// URI
        val uri = if (SystemInfo.isWindows) {
            "file:///$expandedPath" // file:///C:/Users/...
        } else {
            "file://$expandedPath" // file:///Users/...
        }

        println("🗂️  Opening file with URI: $uri")

        val virtualFile = VirtualFileManager.getInstance()
            .refreshAndFindFileByUrl(uri) // refreshAndFindFileByUrl au lieu de findFileByUrl

        if (virtualFile != null) {
            FileEditorManager.getInstance(project)
                .openFile(virtualFile, true)
        } else {
            println("❌ Virtual file not found: $uri")
        }
    }
}
```

## 📊 Tableau Comparatif

| Fonctionnalité            | VS Code                               | JetBrains                               | Notes                              |
| ------------------------- | ------------------------------------- | --------------------------------------- | ---------------------------------- |
| **Webview**               | Native API                            | JCEF (Chromium embarqué)                | JCEF plus complexe                 |
| **Communication GUI→IDE** | `vscode.postMessage()`                | `window.postIntellijMessage()` (custom) | JetBrains nécessite injection JS   |
| **Communication IDE→GUI** | `webview.postMessage()`               | `browser.executeJavaScriptAsync()`      | JetBrains moins fiable             |
| **Ouverture fichier**     | `vscode.workspace.openTextDocument()` | `VirtualFileManager.findFileByUrl()`    | JetBrains nécessite URI            |
| **Logs**                  | Chrome DevTools intégré               | DevTools via action                     | Plus difficile d'accès             |
| **Timing**                | Synchrone                             | Asynchrone avec queue                   | JetBrains peut perdre des messages |
| **Fiabilité**             | 🟢 Excellente                         | 🟡 Moyenne                              | JCEF peut bugger                   |

## 🎯 Conclusion

**Pourquoi ça marche sur VS Code et pas JetBrains** :

1. **API Native** : VS Code a une API webview native et bien testée
2. **Injection JavaScript** : JetBrains doit injecter manuellement `window.postIntellijMessage`
3. **Timing** : JCEF peut charger plus lentement, les messages arrivent trop tôt
4. **Chemins de Fichiers** : JetBrains est plus strict sur les URIs (file://)
5. **Virtual File System** : JetBrains utilise un VFS qui peut ne pas voir les fichiers hors projet

**Prochaines Étapes** :

1. ✅ Ouvrir DevTools JetBrains (`toggleDevTools`)
2. ✅ Vérifier que `window.postIntellijMessage` existe
3. ✅ Ajouter des logs dans Kotlin pour voir où ça bloque
4. ✅ Tester l'ouverture manuelle de fichier
5. ✅ Vérifier que le Core Process tourne

---

**Références** :

- VS Code Webview API : https://code.visualstudio.com/api/extension-guides/webview
- JetBrains JCEF : https://plugins.jetbrains.com/docs/intellij/jcef.html
- Continue Codebase : Le code source actuel montre déjà la différence d'implémentation
