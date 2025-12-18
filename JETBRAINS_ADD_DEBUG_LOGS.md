# 🔧 Ajouter des Logs de Debug - Extension JetBrains

## 🎯 Objectif

Ajouter des logs pour comprendre pourquoi :

1. Le bouton "Configure" ne fait rien
2. Le chat tourne dans le vide

## 📍 Fichiers à Modifier

### 1. ContinueBrowser.kt - Vérifier l'Envoi de Messages

**Fichier** : `extensions/intellij/src/main/kotlin/com/github/continuedev/continueintellijextension/browser/ContinueBrowser.kt`

**Modifier la fonction `sendToWebview()`** (ligne ~87) :

```kotlin
fun sendToWebview(messageType: String, data: Any? = null, messageId: String = uuid()) {
    // VaultAI DEBUG: Log tous les messages envoyés
    log.info("📤 VAULTAI DEBUG: sendToWebview called - messageType=$messageType, messageId=$messageId, isPageLoaded=$isPageLoaded")

    // VaultAI: Queue messages if page is not loaded yet
    if (!isPageLoaded) {
        synchronized(messageQueue) {
            messageQueue.add(Triple(messageType, data, messageId))
        }
        log.info("⏸️  VAULTAI DEBUG: Message queued (page not loaded) - messageType=$messageType")
        return
    }
    sendToWebviewDirect(messageType, data, messageId)
}

private fun sendToWebviewDirect(messageType: String, data: Any? = null, messageId: String = uuid()) {
    val json = Gson().toJson(BrowserMessage(messageType, messageId, data))
    log.info("✅ VAULTAI DEBUG: Sending message to webview - messageType=$messageType, json=$json")

    val jsCode = """window.postMessage($json, "*");"""
    try {
        browser.executeJavaScriptAsync(jsCode)
        log.info("✅ VAULTAI DEBUG: JavaScript executed successfully for messageType=$messageType")
    } catch (error: IllegalStateException) {
        log.warn("❌ VAULTAI DEBUG: Failed to execute JavaScript - error=$error")
        log.warn(error)
    }
}
```

**Modifier le callback OnPageLoad** (ligne ~72) :

```kotlin
browser.jbCefClient.addLoadHandler(OnPageLoad {
    log.info("🌐 VAULTAI DEBUG: Page loaded! Executing initialization JavaScript")
    executeJavaScript(myJSQueryOpenInBrowser)

    // VaultAI: Mark page as loaded and flush queued messages
    isPageLoaded = true
    log.info("📨 VAULTAI DEBUG: Flushing ${messageQueue.size} queued messages")

    synchronized(messageQueue) {
        messageQueue.forEach { (messageType, data, messageId) ->
            log.info("📤 VAULTAI DEBUG: Flushing queued message - messageType=$messageType")
            sendToWebviewDirect(messageType, data, messageId)
        }
        messageQueue.clear()
    }
    log.info("✅ VAULTAI DEBUG: All queued messages flushed")
}, browser.cefBrowser)
```

### 2. ContinuePluginActions.kt - Log Quand le Bouton est Cliqué

**Fichier** : `extensions/intellij/src/main/kotlin/com/github/continuedev/continueintellijextension/actions/ContinuePluginActions.kt`

**Modifier `OpenConfigAction`** (ligne ~83) :

```kotlin
class OpenConfigAction : ContinueToolbarAction() {
    override fun toolbarActionPerformed(project: Project)  {
        println("🔧 VAULTAI DEBUG: OpenConfigAction clicked!")
        val browser = project.getBrowser()
        println("🔧 VAULTAI DEBUG: Browser instance = $browser")

        browser?.sendToWebview("navigateTo", mapOf("path" to "/config", "toggle" to true))
        println("🔧 VAULTAI DEBUG: sendToWebview called for navigateTo")
    }
}
```

### 3. IdeProtocolClient.kt - Log Réception des Messages GUI

**Fichier** : `extensions/intellij/src/main/kotlin/com/github/continuedev/continueintellijextension/continue/IdeProtocolClient.kt`

**Au début de `handleMessage()`** (ligne ~53) :

```kotlin
fun handleMessage(msg: String, respond: (Any?) -> Unit) {
    println("📥 VAULTAI DEBUG: handleMessage received - msg length=${msg.length}")

    coroutineScope.launch(limitedDispatcher) {
        val message = Gson().fromJson(msg, Message::class.java)
        val messageType = message.messageType
        val dataElement = message.data

        println("📥 VAULTAI DEBUG: Parsed message - messageType=$messageType")

        try {
            when (messageType) {
                "showFile" -> {
                    println("📂 VAULTAI DEBUG: showFile handler triggered")
                    val params = Gson().fromJson(
                        dataElement.toString(),
                        ShowFilePayload::class.java
                    )
                    println("📂 VAULTAI DEBUG: Opening file - filepath=${params.filepath}")
                    ide.openFile(params.filepath)
                    println("✅ VAULTAI DEBUG: File opened successfully")
                    respond(null)
                }

                "openFile" -> {
                    println("📂 VAULTAI DEBUG: openFile handler triggered")
                    val params = Gson().fromJson(
                        dataElement.toString(),
                        OpenFileParams::class.java
                    )
                    println("📂 VAULTAI DEBUG: Opening file - path=${params.path}")
                    ide.openFile(params.path)
                    println("✅ VAULTAI DEBUG: File opened successfully")
                    respond(null)
                }
```

### 4. IntelliJIDE.kt - Log l'Ouverture de Fichier

**Fichier** : `extensions/intellij/src/main/kotlin/com/github/continuedev/continueintellijextension/continue/IntelliJIDE.kt`

Cherche la fonction `openFile()` et ajoute des logs :

```kotlin
override fun openFile(filepath: String) {
    println("🗂️  VAULTAI DEBUG: openFile called - filepath=$filepath")

    ApplicationManager.getApplication().invokeLater {
        try {
            val virtualFile = VirtualFileManager.getInstance().findFileByUrl("file://$filepath")
            println("🗂️  VAULTAI DEBUG: Virtual file resolved - virtualFile=$virtualFile")

            if (virtualFile != null) {
                FileEditorManager.getInstance(project).openFile(virtualFile, true)
                println("✅ VAULTAI DEBUG: File opened in editor successfully")
            } else {
                println("❌ VAULTAI DEBUG: Virtual file is null - file not found?")
            }
        } catch (e: Exception) {
            println("❌ VAULTAI DEBUG: Exception opening file - ${e.message}")
            e.printStackTrace()
        }
    }
}
```

## 🏗️ Rebuild de l'Extension

Après avoir ajouté les logs :

```bash
cd extensions/intellij
./gradlew clean buildPlugin

# Le nouveau .zip sera dans build/distributions/
ls -lh build/distributions/
```

## 📊 Comment Voir les Logs

### Logs `println()` et `log.info()`

Les `println()` apparaissent dans la console IntelliJ (Run tool window).

Les `log.info()` apparaissent dans :

```bash
# macOS
tail -f ~/Library/Logs/JetBrains/WebStorm2024.3/idea.log | grep "VAULTAI DEBUG"

# Linux
tail -f ~/.cache/JetBrains/WebStorm2024.3/log/idea.log | grep "VAULTAI DEBUG"

# Windows
Get-Content "$env:USERPROFILE\AppData\Local\JetBrains\WebStorm2024.3\log\idea.log" -Wait -Tail 100 | Select-String "VAULTAI DEBUG"
```

### Voir TOUS les Logs en Temps Réel

```bash
# Ouvre un terminal et lance :
tail -f ~/Library/Logs/JetBrains/WebStorm2024.3/idea.log | grep -i "vaultai\|continue"
```

## 🧪 Tests à Faire Après Rebuild

### Test 1 : Cliquer sur le Bouton "Configure"

1. Installer la nouvelle extension
2. Redémarrer WebStorm
3. Cliquer sur le bouton "Configure" (icône d'engrenage)
4. Regarder les logs

**Logs attendus** :

```
🔧 VAULTAI DEBUG: OpenConfigAction clicked!
🔧 VAULTAI DEBUG: Browser instance = ContinueBrowser@...
🔧 VAULTAI DEBUG: sendToWebview called for navigateTo
📤 VAULTAI DEBUG: sendToWebview called - messageType=navigateTo, ...
✅ VAULTAI DEBUG: JavaScript executed successfully for messageType=navigateTo
```

### Test 2 : Envoyer un Message au Chat

1. Taper un message dans le chat
2. Appuyer sur Entrée
3. Regarder les logs

**Logs attendus** :

```
📥 VAULTAI DEBUG: handleMessage received - msg length=...
📥 VAULTAI DEBUG: Parsed message - messageType=llm/streamChat
...
```

## 🔍 Interprétation des Logs

### Scénario 1 : Bouton Configure Ne Fait Rien

**Si tu vois** :

```
🔧 VAULTAI DEBUG: OpenConfigAction clicked!
🔧 VAULTAI DEBUG: Browser instance = null
```

**→ Problème** : Le browser n'est pas initialisé. Le webview n'a pas démarré.

**Si tu vois** :

```
🔧 VAULTAI DEBUG: OpenConfigAction clicked!
🔧 VAULTAI DEBUG: Browser instance = ContinueBrowser@...
⏸️  VAULTAI DEBUG: Message queued (page not loaded) - messageType=navigateTo
```

**→ Problème** : La page webview n'est pas encore chargée. Le message est mis en queue mais jamais flushé.

**Si tu vois** :

```
✅ VAULTAI DEBUG: JavaScript executed successfully for messageType=navigateTo
```

**→ Problème** : Le message est envoyé mais le GUI React ne le reçoit pas ou ne le traite pas.

### Scénario 2 : Chat Tourne dans le Vide

**Si tu ne vois AUCUN log après avoir envoyé un message** :
**→ Problème** : La communication GUI → Kotlin est cassée. `window.postIntellijMessage` n'existe pas ou ne fonctionne pas.

**Si tu vois** :

```
📥 VAULTAI DEBUG: handleMessage received - msg length=...
📥 VAULTAI DEBUG: Parsed message - messageType=llm/streamChat
```

**→ Problème** : Le message arrive au Kotlin mais n'est pas transmis au Core ou le Core ne répond pas.

## 🚀 Version Simplifiée - Log Minimal

Si tu veux juste un log rapide sans tout modifier, ajoute juste ça dans `OpenConfigAction` :

```kotlin
class OpenConfigAction : ContinueToolbarAction() {
    override fun toolbarActionPerformed(project: Project)  {
        System.err.println("==========================================")
        System.err.println("VAULTAI DEBUG: Config button clicked!")
        System.err.println("Browser exists: ${project.getBrowser() != null}")
        System.err.println("==========================================")

        project.getBrowser()?.sendToWebview("navigateTo", mapOf("path" to "/config", "toggle" to true))
    }
}
```

Utilise `System.err.println()` car ça apparaît toujours dans les logs, même sans configuration spéciale.

## 📦 Commandes Complètes

```bash
# 1. Ajouter les logs de debug (éditer les fichiers manuellement)

# 2. Rebuild
cd extensions/intellij
./gradlew clean buildPlugin

# 3. Copier vers Desktop
cp build/distributions/vaultai-code-assistant-intellij-*.zip ~/Desktop/

# 4. Installer dans WebStorm
# File > Settings > Plugins > ⚙️ > Install Plugin from Disk > Sélectionner le .zip

# 5. Redémarrer WebStorm

# 6. Ouvrir les logs en temps réel
tail -f ~/Library/Logs/JetBrains/WebStorm2024.3/idea.log | grep -E "VAULTAI|ERROR|Exception"

# 7. Tester le bouton Configure et le chat
```

---

**Résumé** : Avec ces logs, on saura exactement où le problème se situe :

- ❌ Bouton pas capté → Pas de log `OpenConfigAction clicked`
- ❌ Browser pas initialisé → `Browser instance = null`
- ❌ Message pas envoyé → Pas de log `sendToWebview called`
- ❌ Page pas chargée → Message en queue mais jamais flushé
- ❌ JavaScript pas exécuté → Erreur d'exécution JavaScript
- ❌ Message pas reçu par le GUI → Message envoyé mais pas de réaction
