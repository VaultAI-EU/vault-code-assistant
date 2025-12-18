# ⚡ Guide Rapide : Fixer JetBrains en 10 Minutes

## 🎯 Objectif

Diagnostiquer et fixer :

1. ❌ Bouton "Configure" qui ne fait rien
2. ❌ Chat qui tourne dans le vide

## 📋 Étape 1 : Ouvrir les DevTools (2 min)

### Dans WebStorm

1. Ouvrir l'outil VaultAI (barre latérale gauche, icône Continue)
2. Appuyer sur **Ctrl+Shift+A** (ou Cmd+Shift+A sur Mac)
3. Taper `toggleDevTools`
4. Appuyer sur Entrée

→ Une fenêtre Chrome DevTools devrait s'ouvrir

**Alternative si ça ne marche pas** :

```
View > Tool Windows > Continue
Clic droit sur le panneau Continue > Inspect
```

## 📋 Étape 2 : Tester la Communication (3 min)

### Dans la Console DevTools

Copie et colle ces commandes **une par une** :

```javascript
// Test 1 : Vérifier que postIntellijMessage existe
console.log("Test 1:", typeof window.postIntellijMessage);
// ✅ Attendu: "function"
// ❌ Si "undefined" → Problème d'injection JS

// Test 2 : Vérifier que postMessage existe
console.log("Test 2:", typeof window.postMessage);
// ✅ Attendu: "function"

// Test 3 : Écouter les messages
window.addEventListener("message", (e) => {
  console.log("📨 Message reçu:", e.data);
});
console.log("✅ Listener ajouté");

// Test 4 : Envoyer un message de test au plugin
if (window.postIntellijMessage) {
  window.postIntellijMessage("getIdeInfo", {}, "test-123");
  console.log("✅ Message envoyé");
} else {
  console.error("❌ postIntellijMessage n'existe pas");
}
```

### Résultats à Noter

**Scénario A** : `window.postIntellijMessage` est `undefined`

```
→ Problème : Le JavaScript n'a pas été injecté
→ Cause : La page s'est chargée avant l'injection
→ Fix : Voir section "Fix 1" ci-dessous
```

**Scénario B** : La fonction existe mais aucune réponse après Test 4

```
→ Problème : La communication Plugin→GUI est cassée
→ Cause : Le Core Process ne tourne pas ou ne répond pas
→ Fix : Voir section "Fix 2" ci-dessous
```

**Scénario C** : Tout fonctionne, un message apparaît après Test 4

```
→ Problème ailleurs : Navigation ou handlers React
→ Fix : Voir section "Fix 3" ci-dessous
```

## 📋 Étape 3 : Vérifier les Logs (2 min)

### Ouvrir le Terminal

```bash
# macOS
tail -f ~/Library/Logs/JetBrains/WebStorm2024.3/idea.log | grep -i "continue\|vaultai"

# Linux
tail -f ~/.cache/JetBrains/WebStorm2024.3/log/idea.log | grep -i "continue\|vaultai"

# Windows (PowerShell)
Get-Content "$env:USERPROFILE\AppData\Local\JetBrains\WebStorm2024.3\log\idea.log" -Wait -Tail 50 | Select-String "continue|vaultai"
```

### Ouvrir les Logs Continue Core

```bash
# Tous systèmes
tail -f ~/.continue/logs/core.log
```

Laisser les deux terminaux ouverts, puis passer à l'étape 4.

## 📋 Étape 4 : Tester le Bouton Configure (1 min)

### Dans WebStorm

1. Cherche l'icône **⚙️ (engrenage)** dans le toolbar de Continue
2. Clique dessus
3. **Regarde simultanément** :
   - Les DevTools (console JavaScript)
   - Le terminal avec `idea.log`
   - Le terminal avec `core.log`

### Analyse des Résultats

**Tu devrais voir dans `idea.log`** :

```
INFO - ...ContinuePluginActions - OpenConfigAction triggered
```

❌ **Si tu ne vois rien** → Le bouton n'est pas connecté

**Tu devrais voir dans DevTools** :

```
📨 Message reçu: {messageType: "navigateTo", data: {path: "/config", ...}}
```

❌ **Si tu ne vois rien** → Le message n'arrive pas au GUI

## 📋 Étape 5 : Tester le Chat (1 min)

### Dans WebStorm

1. Ouvre un fichier quelconque
2. Appuie sur **Ctrl+L** (ou Cmd+L)
3. Tape un message simple : `"Hello"`
4. Appuie sur Entrée
5. **Regarde les logs** (terminaux ouverts à l'étape 3)

### Analyse des Résultats

**Tu devrais voir dans `core.log`** :

```
[INFO] Received message: llm/streamChat
[INFO] Using model: claude-sonnet-4
...
```

❌ **Si tu ne vois rien** → Le Core Process ne tourne pas

**Tu devrais voir dans DevTools** :

```
📨 Message reçu: {messageType: "llm/streamChat", ...}
```

❌ **Si tu ne vois rien** → La communication est cassée

## 🔧 Fixes selon les Résultats

### Fix 1 : postIntellijMessage Undefined

**Problème** : JavaScript pas injecté dans le webview.

**Solution Temporaire** :

```javascript
// Dans DevTools Console
window.postIntellijMessage = function (messageType, data, messageId) {
  console.log("Manual injection:", messageType, data);
  // Cette fonction ne fera rien mais au moins on peut tester le GUI
};
```

**Solution Permanente** :

1. Ouvre `extensions/intellij/src/main/kotlin/.../browser/ContinueBrowser.kt`
2. Ajoute un log dans `executeJavaScript()` :
   ```kotlin
   val script = """
       window.postIntellijMessage = function(messageType, data, messageId) {
           const msg = JSON.stringify({messageType, data, messageId});
           ${myJSQueryOpenInBrowser.inject("msg")}
       }
       console.log("✅ postIntellijMessage injected");
   """
   ```
3. Rebuild : `cd extensions/intellij && ./gradlew buildPlugin`
4. Réinstaller le plugin

### Fix 2 : Core Process Ne Tourne Pas

**Vérification** :

```bash
ps aux | grep continue
```

**Si aucun process** :

```
WebStorm > Ctrl+Shift+A > "Restart Continue Process"
```

**Si erreur au démarrage**, check `core.log` :

```bash
cat ~/.continue/logs/core.log | grep -i error
```

**Problèmes courants** :

- ❌ Port déjà utilisé → Tuer le process : `pkill -f continue`
- ❌ Node.js pas trouvé → Installer Node.js 20+
- ❌ Permissions → `chmod -R 755 ~/.continue`

### Fix 3 : Navigation React Ne Marche Pas

**Test dans DevTools** :

```javascript
// Forcer la navigation manuellement
window.dispatchEvent(
  new MessageEvent("message", {
    data: {
      messageType: "navigateTo",
      data: { path: "/config", toggle: false },
      messageId: "manual-test",
    },
  }),
);
```

**Si ça fonctionne** → Le problème est dans l'envoi du message depuis Kotlin.

**Si ça ne fonctionne pas** → Le problème est dans le listener React.

### Fix 4 : Ouvrir config.yaml Manuellement

**Dans DevTools** :

```javascript
// Tester l'ouverture de fichier directement
window.postIntellijMessage(
  "showFile",
  {
    filepath: "/Users/TON-USERNAME/.continue/config.yaml",
  },
  "manual-open-file",
);

// Remplace TON-USERNAME par ton nom d'utilisateur
```

**Si ça ne fonctionne pas**, essaie avec le chemin absolu complet :

```bash
# Dans le terminal, trouve le chemin
realpath ~/.continue/config.yaml
# Copie le résultat et utilise-le dans showFile
```

## 🎯 Résumé des Diagnostics

| Symptôme                        | Cause Probable         | Fix                            |
| ------------------------------- | ---------------------- | ------------------------------ |
| `postIntellijMessage` undefined | JS pas injecté         | Fix 1                          |
| Aucun log dans `core.log`       | Core Process arrêté    | Fix 2                          |
| Message envoyé mais pas reçu    | JCEF timing issue      | Redémarrer WebStorm            |
| Bouton Configure ne fait rien   | Action pas enregistrée | Vérifier `plugin.xml`          |
| Chat tourne sans fin            | Model pas configuré    | Ouvrir config et ajouter model |

## 📞 Si Rien Ne Marche

### Collecte d'Informations

Exécute ces commandes et sauvegarde les résultats :

```bash
# 1. Version WebStorm
echo "WebStorm Version:" && grep -i version ~/Library/Application\ Support/JetBrains/WebStorm*/product-info.json 2>/dev/null || echo "WebStorm version unknown"

# 2. Process Continue
echo "Continue Processes:" && ps aux | grep -i continue | grep -v grep

# 3. Dernières erreurs
echo "Recent Errors in Core Log:" && tail -50 ~/.continue/logs/core.log | grep -i error

# 4. Test de postIntellijMessage (ouvre DevTools d'abord)
echo "Run in DevTools: console.log(typeof window.postIntellijMessage)"

# 5. Contenu config
echo "Config File Exists:" && ls -la ~/.continue/config.yaml

# 6. Permissions
echo "Permissions:" && ls -ld ~/.continue
```

### Partage ces Infos

Copie-colle les résultats + une capture d'écran de :

1. La console DevTools (avec les tests de l'étape 2)
2. Le panneau Continue de WebStorm
3. Le contenu de `idea.log` (dernières 50 lignes)

## ✅ Checklist Finale

Avant de dire que c'est cassé, vérifie :

- [ ] WebStorm redémarré après installation du plugin
- [ ] DevTools ouvre correctement
- [ ] `window.postIntellijMessage` existe (type "function")
- [ ] `core.log` contient des logs récents (< 5 min)
- [ ] Le fichier `~/.continue/config.yaml` existe
- [ ] Un modèle est configuré dans config.yaml
- [ ] Les logs `idea.log` ne montrent pas d'erreurs JCEF

Si tout est ✅ mais ça ne marche toujours pas → C'est un bug spécifique à résoudre.

## 🚀 Quick Win : Test Minimal

Si tu veux juste tester que la communication fonctionne :

```javascript
// Dans DevTools Console
async function testCommunication() {
  console.log("🧪 Testing communication...");

  // Test 1
  console.log(
    "1. postIntellijMessage exists?",
    typeof window.postIntellijMessage,
  );

  // Test 2
  if (typeof window.postIntellijMessage !== "function") {
    console.error("❌ FAIL: postIntellijMessage missing");
    return;
  }

  // Test 3
  let received = false;
  const listener = (e) => {
    if (e.data.messageId === "quick-test") {
      received = true;
      console.log("✅ SUCCESS: Received response", e.data);
    }
  };
  window.addEventListener("message", listener);

  // Test 4
  window.postIntellijMessage("getIdeInfo", {}, "quick-test");
  console.log("📤 Message sent, waiting for response...");

  // Wait 2 seconds
  await new Promise((r) => setTimeout(r, 2000));

  if (!received) {
    console.error("❌ FAIL: No response after 2s");
  }

  window.removeEventListener("message", listener);
}

testCommunication();
```

**Résultat attendu** : `✅ SUCCESS: Received response` avec les infos de l'IDE.

---

**Durée totale estimée** : 10-15 minutes  
**Difficulté** : 🟡 Moyenne (nécessite d'ouvrir DevTools)  
**Requis** : WebStorm, Extension installée, Terminal
