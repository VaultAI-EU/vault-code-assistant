# 🐛 Guide de Debugging JetBrains - VaultAI Extension

## 🔍 Problèmes Identifiés

Sur WebStorm :

1. ❌ Le bouton "Configure" (réglages) ne fait rien au clic
2. ❌ Le chat tourne dans le vide sans répondre
3. ✅ L'interface GUI s'affiche correctement

Sur VS Code :

- ✅ Tout fonctionne parfaitement

## 📊 Comment Accéder aux Logs JetBrains

### 1. Logs du Plugin Continue

**Méthode 1 : Via l'action "Open Logs"**

```
WebStorm > Tools > Continue > Open Logs
```

ou

```
Ctrl+Shift+A (Cmd+Shift+A sur Mac)
Taper "Open Logs"
Sélectionner "Continue: Open Logs"
```

Cela ouvre le fichier : `~/.continue/logs/core.log`

**Méthode 2 : Manuellement**

```bash
# macOS/Linux
tail -f ~/.continue/logs/core.log

# Windows
Get-Content "$env:USERPROFILE\.continue\logs\core.log" -Wait -Tail 50
```

### 2. Logs de l'IDE JetBrains

**Emplacement des logs** :

```bash
# macOS
~/Library/Logs/JetBrains/WebStorm2024.3/idea.log

# Linux
~/.cache/JetBrains/WebStorm2024.3/log/idea.log

# Windows
%USERPROFILE%\AppData\Local\JetBrains\WebStorm2024.3\log\idea.log
```

**Ouvrir les logs en live** :

```
Help > Show Log in Finder/Explorer
```

ou

```
Help > Diagnostic Tools > Debug Log Settings
```

### 3. Logs de la Console JavaScript (Webview)

Le GUI React tourne dans un JCEF (Java Chromium Embedded Framework). Pour voir les logs JavaScript :

**Ouvrir DevTools** :

1. Cliquer sur l'icône VaultAI dans la barre latérale
2. Dans le panneau Continue, faire **Ctrl+Shift+A** (Cmd+Shift+A)
3. Taper "toggleDevTools" ou "Continue: Toggle Dev Tools"
4. Cliquer dessus pour ouvrir Chrome DevTools

**Alternative** : Ajouter temporairement un bouton de debug dans le GUI

## 🔬 Tests de Diagnostic

### Test 1 : Vérifier la Communication Webview → Plugin

Ouvre les DevTools (voir ci-dessus) et tape dans la console :

```javascript
// Test si postIntellijMessage existe
console.log(window.postIntellijMessage);

// Test d'envoi de message
window.postIntellijMessage(
  "showFile",
  { filepath: "/Users/ton-user/.continue/config.yaml" },
  "test-message-id",
);
```

**Résultat attendu** :

- Si `window.postIntellijMessage` est `undefined` → Problème d'injection JavaScript
- Si c'est une fonction mais rien ne se passe → Problème dans le handler Kotlin

### Test 2 : Vérifier que les Messages Arrivent au Handler

Dans les logs JetBrains (`idea.log`), cherche :

```
Unknown message type: navigateTo
```

ou

```
Error handling message of type
```

### Test 3 : Tester l'Ouverture de Fichier Manuellement

Dans WebStorm, ouvre le terminal intégré et teste :

```bash
# Vérifie que le fichier config existe
ls -la ~/.continue/config.yaml

# Note le chemin complet
realpath ~/.continue/config.yaml
```

Puis dans le code Kotlin, on devrait voir l'appel à `openFile()`.

## 🔧 Fixes Potentiels

### Fix 1 : Page Webview Pas Encore Chargée

**Symptôme** : Les messages sont envoyés avant que le GUI soit prêt.

**Solution** : Dans `ContinueBrowser.kt`, on a déjà un système de queue :

```kotlin
if (!isPageLoaded) {
    synchronized(messageQueue) {
        messageQueue.add(Triple(messageType, data, messageId))
    }
    log.info("Queued message $messageType (page not loaded yet)")
    return
}
```

Vérifie dans les logs si tu vois : `"Queued message navigateTo (page not loaded yet)"`

### Fix 2 : Chemin du Fichier Config Incorrect

**Symptôme** : `ide.openFile()` est appelé mais avec un mauvais chemin.

**Solution** : Vérifie le format du chemin :

- macOS/Linux : `/Users/username/.continue/config.yaml`
- Windows : `C:\Users\username\.continue\config.yaml`

Dans JetBrains, le chemin doit être :

- Soit un chemin absolu
- Soit un `file://` URI

### Fix 3 : Chat Tourne dans le Vide - Core Process Pas Lancé

**Symptôme** : Le core process (serveur Node.js) n'est pas démarré.

**Vérification** :

```bash
# Cherche le process Continue
ps aux | grep continue

# Vérifie les logs
tail -f ~/.continue/logs/core.log
```

**Solution** : Force le redémarrage du process :

```
Ctrl+Shift+A > "Continue: Restart Core Process"
```

## 📝 Commandes de Debug Utiles

### Dans WebStorm

```
# Ouvrir les logs
Help > Show Log in Finder/Explorer

# Redémarrer le plugin
Ctrl+Shift+A > "Restart Continue Process"

# Ouvrir DevTools pour le webview
Ctrl+Shift+A > "toggleDevTools"

# Désactiver/Réactiver le plugin
File > Settings > Plugins > Continue > Disable/Enable
```

### Dans le Terminal

```bash
# Voir les logs en temps réel
tail -f ~/.continue/logs/core.log

# Vérifier que le fichier config existe
ls -la ~/.continue/config.yaml

# Chercher les erreurs dans les logs
grep -i error ~/.continue/logs/core.log

# Nettoyer le cache JetBrains
rm -rf ~/Library/Caches/JetBrains/WebStorm2024.3/
```

## 🎯 Plan d'Action Prioritaire

1. **Ouvrir les DevTools** du webview et vérifier la console JavaScript
2. **Vérifier `window.postIntellijMessage`** existe
3. **Tester manuellement** l'envoi de messages depuis la console
4. **Checker les logs** `~/.continue/logs/core.log` pour voir si le core tourne
5. **Regarder idea.log** pour voir les erreurs Kotlin/Java

## 🚨 Erreurs Communes

### Erreur : "postIntellijMessage is undefined"

```
Unable to send message: postIntellijMessage is undefined.
```

**Cause** : Le script JavaScript n'a pas été injecté dans le webview.

**Solution** : Vérifier que `executeJavaScript()` s'exécute après le chargement de la page dans `ContinueBrowser.kt` ligne 61-70.

### Erreur : "Unknown message type: navigateTo"

```
Unknown message type: navigateTo
```

**Cause** : Le message `navigateTo` arrive au Kotlin mais n'est pas géré dans `IdeProtocolClient.kt`.

**Solution** : Le message `navigateTo` est géré par le **GUI React**, pas par le Kotlin. C'est un message IDE → GUI, donc il doit passer par `sendToWebview()`.

**Vérification** :

- `OpenConfigAction` (Kotlin) → appelle `sendToWebview("navigateTo", ...)`
- `Layout.tsx` (React) → `useWebviewListener("navigateTo", ...)` doit le recevoir

### Chat Tourne dans le Vide

**Causes possibles** :

1. Core process pas démarré
2. Modèle pas configuré
3. Erreur de communication GUI ↔ Core

**Debug** :

```bash
# 1. Vérifie que le core tourne
tail -f ~/.continue/logs/core.log

# 2. Cherche les erreurs
grep -i "error\|exception" ~/.continue/logs/core.log

# 3. Teste si le process répond
lsof -i :65432  # Port par défaut du core
```

## 📞 Informations à Fournir pour le Debug

Si le problème persiste, fournis :

1. **Logs JetBrains** :

   ```bash
   tail -100 ~/Library/Logs/JetBrains/WebStorm2024.3/idea.log
   ```

2. **Logs Continue Core** :

   ```bash
   tail -100 ~/.continue/logs/core.log
   ```

3. **Console DevTools** (après avoir ouvert les DevTools du webview) :

   - Capture d'écran ou copie des erreurs JavaScript

4. **Version de WebStorm** :

   ```
   Help > About > Copier les informations
   ```

5. **Test de `window.postIntellijMessage`** :
   ```javascript
   console.log(typeof window.postIntellijMessage);
   console.log(window.postIntellijMessage);
   ```

## 🔄 Redémarrage Complet

Si rien ne marche, essaie un redémarrage complet :

```bash
# 1. Fermer WebStorm complètement

# 2. Tuer les process Continue
pkill -f continue

# 3. Nettoyer les caches
rm -rf ~/Library/Caches/JetBrains/WebStorm2024.3/

# 4. Supprimer les logs temporaires
rm -f ~/.continue/logs/*.log

# 5. Redémarrer WebStorm

# 6. Réactiver le plugin Continue
File > Settings > Plugins > Continue > Disable puis Enable
```

---

**Statut** : En attente de logs pour diagnostic  
**Prochaine étape** : Ouvrir DevTools et vérifier `window.postIntellijMessage`
