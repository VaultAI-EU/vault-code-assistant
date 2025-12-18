# 🏗️ VaultAI VSCode Extension - Guide de Build

Ce document explique comment builder et packager l'extension VaultAI pour VS Code.

## 📋 Prérequis

- Node.js >= 20.19.0
- npm >= 9.0.0
- Git

## 🚀 Build Rapide

### Linux / macOS

```bash
# Depuis le dossier extensions/vscode/
chmod +x scripts/build-all.sh
./scripts/build-all.sh
```

### Windows

```powershell
# Depuis le dossier extensions/vscode/
.\scripts\build-all.ps1
```

## 🎯 Options de Build

### Build pour une plateforme spécifique

```bash
# Linux / macOS
./scripts/build-all.sh --target linux-x64
./scripts/build-all.sh --target darwin-arm64
./scripts/build-all.sh --target win32-x64

# Windows
.\scripts\build-all.ps1 -Target win32-x64
```

### Build en Pre-release

```bash
# Linux / macOS
./scripts/build-all.sh --pre-release

# Windows
.\scripts\build-all.ps1 -PreRelease
```

### Skip GUI Build (si déjà construit)

```bash
# Linux / macOS
./scripts/build-all.sh --skip-gui

# Windows
.\scripts\build-all.ps1 -SkipGui
```

## 📦 Processus de Build

Le script `build-all` effectue les étapes suivantes dans l'ordre :

### 1. **Build du GUI (React App)**

- Compile le code React/TypeScript
- Génère les fichiers statiques dans `gui/dist/`
- Vérifie que `index.js` et `index.css` sont présents

### 2. **Prepackage**

- Copie le GUI build vers `extensions/vscode/gui/`
- Copie les binaires natifs (onnxruntime, sqlite3, etc.)
- Installe les dépendances nécessaires

### 3. **Compilation TypeScript**

- Compile le code TypeScript de l'extension
- Génère les fichiers dans `out/`

### 4. **Package**

- Crée le fichier `.vsix` dans `build/`

## 🔧 Build Manuel (étape par étape)

Si vous préférez builder manuellement :

### 1. Build du GUI

```bash
cd gui/
npm install
npm run build
cd ..
```

### 2. Prepackage

```bash
cd extensions/vscode/
npm install
node scripts/prepackage.js
```

### 3. Compilation

```bash
npm run esbuild
```

### 4. Package

```bash
node scripts/package.js
```

## ⚠️ Problèmes Courants

### ❌ "GUI build failed - index.js not found"

**Cause**: Le GUI n'a pas été construit correctement.

**Solution**:

```bash
cd gui/
rm -rf dist node_modules
npm install
npm run build
```

### ❌ "command 'continue.xxx' not found"

**Cause**: Le GUI n'est pas inclus dans l'extension, ou les commandes ne sont pas enregistrées.

**Solution**:

1. Vérifiez que `extensions/vscode/gui/` existe et contient des fichiers
2. Reconstruisez l'extension complètement :
   ```bash
   rm -rf build/ gui/ out/
   ./scripts/build-all.sh
   ```

### ❌ "Extension does not load"

**Cause**: Binaires natifs manquants ou incompatibles.

**Solution**:

```bash
# Nettoyer complètement
rm -rf node_modules build gui out bin

# Réinstaller les dépendances
npm install

# Rebuilder tout
./scripts/build-all.sh --target <votre-plateforme>
```

## 🎯 Plateformes Supportées

Les plateformes suivantes sont supportées pour le build :

- `linux-x64` - Linux 64-bit (Intel/AMD)
- `linux-arm64` - Linux 64-bit (ARM)
- `darwin-x64` - macOS Intel
- `darwin-arm64` - macOS Apple Silicon (M1/M2/M3)
- `win32-x64` - Windows 64-bit (Intel/AMD)
- `win32-arm64` - Windows ARM64

## 📝 Vérification du Package

Après le build, vous pouvez vérifier le contenu du package :

### Linux / macOS

```bash
unzip -l build/*.vsix | grep -E "(gui|extension.js|node_modules)"
```

### Windows

```powershell
Expand-Archive -Path .\build\*.vsix -DestinationPath .\temp-check\
Get-ChildItem -Path .\temp-check\ -Recurse
Remove-Item -Path .\temp-check\ -Recurse -Force
```

### Points à vérifier :

- ✅ `extension/gui/assets/index.js` existe
- ✅ `extension/gui/assets/index.css` existe
- ✅ `extension/out/extension.js` existe
- ✅ Binaires natifs pour votre plateforme présents

## 🚀 Installation du Package

Une fois le build terminé :

```bash
# Installation directe
code --install-extension ./build/continue-*.vsix

# Ou via VS Code
# 1. Ouvrir VS Code
# 2. Extensions > ... > Install from VSIX
# 3. Sélectionner le fichier .vsix
```

## 🧹 Nettoyage

Pour nettoyer tous les fichiers générés :

```bash
rm -rf build/ gui/ out/ bin/ node_modules/
```

## 📚 Ressources

- [VS Code Extension API](https://code.visualstudio.com/api)
- [vsce Documentation](https://github.com/microsoft/vscode-vsce)
- [VaultAI Documentation](https://docs.vaultai.eu)

## 🐛 Debugging

Pour debugger l'extension pendant le développement :

1. Ouvrir `extensions/vscode` dans VS Code
2. Appuyer sur `F5` pour lancer en mode debug
3. Cela ouvrira une nouvelle fenêtre VS Code avec l'extension chargée

## 🔄 Workflow de Développement Recommandé

1. **Développement du GUI** :

   ```bash
   cd gui/
   npm run dev  # Hot reload
   ```

2. **Développement de l'Extension** :

   ```bash
   cd extensions/vscode/
   npm run esbuild-watch  # Auto-compile
   ```

3. **Test dans VS Code** :

   - Appuyer sur `F5` dans VS Code

4. **Build final** :
   ```bash
   ./scripts/build-all.sh
   ```
