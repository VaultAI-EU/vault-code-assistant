# VaultAI - Guide de Rebuild Complet

Ce guide explique quand et comment rebuild les extensions VaultAI (VS Code et JetBrains) après des modifications.

---

## 📋 Table des Matières

- [Quand Rebuild?](#quand-rebuild)
- [VS Code Extension](#vs-code-extension)
- [JetBrains Extension](#jetbrains-extension)
- [Troubleshooting](#troubleshooting)

---

## Quand Rebuild?

Vous devez rebuild l'extension quand vous modifiez:

### ✅ Toujours rebuild après modifications de:

1. **TypeScript files (.ts, .tsx)** dans `core/`, `extensions/vscode/`, `extensions/intellij/`, ou `gui/src/`
2. **Branding assets** (logos, icons) référencés par l'extension ou le GUI
3. **`package.json`** ou **`package-lock.json`** files
4. **Configuration files** (`plugin.xml`, `gradle.properties` pour JetBrains)

### ⚠️ Signes qu'un rebuild est nécessaire:

- L'extension ne reflète pas vos changements
- Erreurs inattendues lors de l'utilisation
- GUI vide ou logo manquant
- Fonctionnalités qui ne répondent pas

---

## VS Code Extension

### 🔄 Full Rebuild (après changements TypeScript ou GUI)

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant

# 1. Build core
cd core && npm run build && cd ..

# 2. Build GUI
cd gui && npm run build && cd ..

# 3. Build VS Code extension
cd extensions/vscode && npm run esbuild && cd ../..

# 4. Copy GUI to extension
cd extensions/vscode && rm -rf gui && cp -r ../../gui/dist gui && cd ../..
```

### ⚡ Quick Rebuild (core + extension seulement)

Si vous n'avez **pas** modifié le GUI:

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant
cd core && npm run build && cd ../extensions/vscode && npm run esbuild && cd ../..
```

### 🎨 Apply Branding (avant de packager)

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant
node scripts/vaultai/apply-branding.js
```

### 📦 Package Extension (.vsix)

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode
npx @vscode/vsce@latest package --no-dependencies
```

Le fichier `.vsix` sera créé dans `extensions/vscode/`.

### 🔄 Reload VS Code Window

Après le rebuild:

- Dans VS Code: **Command Palette** (`Cmd+Shift+P` ou `Ctrl+Shift+P`)
- Sélectionner: **"Developer: Reload Window"**

Ou si vous debuggez:

- Arrêter le debugger complètement (bouton rouge Stop)
- Appuyer sur **F5** pour relancer l'extension avec le nouveau build

---

## JetBrains Extension

### 🔄 Full Rebuild (après changements)

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant

# 1. Build GUI (avec branding VaultAI)
cd gui && npm run build && cd ..

# 2. Copier GUI vers JetBrains
rm -rf extensions/intellij/src/main/resources/webview/*
cp -r gui/dist/* extensions/intellij/src/main/resources/webview/

# 3. Build binary (core) pour macOS
cd binary && npm run build -- --os darwin && cd ..

# 4. Appliquer branding VaultAI
node scripts/vaultai/apply-branding-intellij.js

# 5. Build plugin JetBrains
cd extensions/intellij && ./gradlew clean buildPlugin && cd ../..
```

Le fichier `.zip` sera créé dans:

```
extensions/intellij/build/distributions/continue-intellij-extension-1.0.0-vaultai.zip
```

### 📥 Installation du Plugin

1. **Désinstaller l'ancien plugin:**

   - IntelliJ: `Settings → Plugins`
   - Chercher "VaultAI" ou "Continue"
   - Cliquer sur l'engrenage → `Uninstall`
   - Redémarrer IntelliJ

2. **Installer le nouveau:**

   - `Settings → Plugins → ⚙️ (engrenage) → Install Plugin from Disk...`
   - Sélectionner: `extensions/intellij/build/distributions/continue-intellij-extension-1.0.0-vaultai.zip`
   - Redémarrer IntelliJ

3. **Vérifier:**
   - Ouvrir un projet (important!)
   - `Vue → Tool Windows → VaultAI`
   - Le panel devrait afficher l'interface VaultAI

### 🐛 Si le Panel JetBrains est Vide

Le problème principal est que le **serveur backend (Node.js) ne démarre pas**.

**1. Vérifier les logs:**

```bash
tail -f ~/Library/Logs/JetBrains/IntelliJIdea*/idea.log
```

Ou dans IntelliJ: `Help → Show Log in Finder`

**2. Chercher des erreurs:**

- Chercher "Continue" ou "VaultAI" dans les logs
- Chercher "Error" ou "Exception"
- Vérifier si le serveur Node démarre

**3. Causes courantes:**

❌ **Node.js pas installé:**

```bash
node --version  # Doit être v20+
```

❌ **Binaire non exécutable:**

```bash
chmod +x ~/.continue/binaries/continue-*/continue-darwin-arm64
```

❌ **Projet pas ouvert:**

- Ouvrir un projet pour que le plugin s'active

❌ **JCEF désactivé:**

- `Help → Find Action → "Registry"`
- Chercher `ide.browser.jcef.enabled` → doit être activé

**4. Debugger en mode développement:**

- Ouvrir le projet `extensions/intellij` dans IntelliJ IDEA
- Lancer "Run Continue" depuis les configurations
- Cela ouvrira une nouvelle instance avec debug activé

---

## Troubleshooting

### Extension ne se charge pas (VS Code)

**Symptôme:** Extension non listée ou erreur au démarrage

**Solution:**

1. Vérifier que `package.json` n'a pas été corrompu
2. Vérifier que le branding a été appliqué correctement
3. Rebuild complet + reload window

### GUI vide ou logo manquant

**Symptôme:** Panel blanc ou logo Continue au lieu de VaultAI

**Solution:**

1. Rebuild le GUI: `cd gui && npm run build`
2. Copier vers l'extension (voir commandes ci-dessus)
3. Rebuild l'extension
4. Reload

### Anthropic "text content blocks must be non-empty"

**Symptôme:** Erreur lors de l'utilisation de modèles Anthropic

**Solution:**

- Ce bug est normalement fixé dans `core/llm/llms/Anthropic.ts`
- Si l'erreur persiste, rebuild le core:
  ```bash
  cd core && npm run build
  ```

### AWS Bedrock region non sauvegardé

**Symptôme:** Erreur `getaddrinfo ENOTFOUND bedrock-runtime.undefined.amazonaws.com`

**Solution:**

- Vérifier que les modifications dans `core/config/util.ts` et `packages/config-yaml/src/schemas/models.ts` sont présentes
- Rebuild le core:
  ```bash
  cd core && npm run build
  ```

### JetBrains: CoreMessenger errors

**Symptôme:** Le plugin s'installe mais le panel reste vide

**Solution:**

1. Vérifier que le binary a été compilé:
   ```bash
   ls -lh ~/.continue/binaries/
   ```
2. Recompiler le binary:
   ```bash
   cd binary && npm run build -- --os darwin
   ```
3. Vérifier les permissions:
   ```bash
   chmod +x ~/.continue/binaries/continue-*/continue-darwin-arm64
   ```

---

## 📝 Notes Importantes

### VS Code

- Le `name` et `publisher` dans `package.json` doivent rester `"continue"` et `"Continue"`
- Ne JAMAIS modifier les IDs de commandes (`continue.*`)
- Le branding se fait via `displayName`, `description`, et assets

### JetBrains

- Le `id` du toolWindow reste `"Continue"` pour compatibilité interne
- Le `displayName="VaultAI"` change le titre visible
- Le GUI est copié dans `src/main/resources/webview/`
- Le binary doit être dans `~/.continue/binaries/`

### Général

- Toujours rebuild le **core** avant l'extension
- Toujours rebuild le **GUI** avant de le copier
- Appliquer le **branding** avant de packager
- **Tester** après chaque build majeur

---

## ✅ Checklist Rebuild Complet

Après des modifications importantes:

- [ ] Build core (`cd core && npm run build`)
- [ ] Build GUI (`cd gui && npm run build`)
- [ ] Copier GUI vers VS Code et/ou JetBrains
- [ ] Build binary si nécessaire (`cd binary && npm run build -- --os darwin`)
- [ ] Apply branding (`node scripts/vaultai/apply-branding*.js`)
- [ ] Build extension VS Code (`npm run esbuild`)
- [ ] Build plugin JetBrains (`./gradlew clean buildPlugin`)
- [ ] Tester VS Code (reload window)
- [ ] Tester JetBrains (reinstall + restart)
- [ ] Vérifier logo VaultAI visible
- [ ] Vérifier chat fonctionnel
- [ ] Vérifier AWS Bedrock dans providers

---

**Dernière mise à jour:** 2025-10-20
