# 🔧 Corrections Apportées à l'Extension VaultAI

## Fix #1 : Copie du binaire LanceDB (2025-11-03)

### 🐛 Problème

Lors du build de l'extension, le binaire LanceDB (`index.node`, ~82 MB) n'était pas copié correctement dans le dossier `out/node_modules/@lancedb/vectordb-<platform>/`.

**Erreur rencontrée** :

```
Error: The following files were missing:
- out/node_modules/@lancedb/vectordb-darwin-arm64/index.node
```

### 🔍 Cause

Le module `ncp` (Node Copy) utilisé avec l'option `dereference: true` ne copie pas correctement les gros fichiers binaires. Il copie bien les petits fichiers texte (README.md, package.json) mais omet le binaire principal.

### ✅ Solution

Ajout d'une copie manuelle explicite du binaire LanceDB après la copie avec `ncp` dans le fichier `scripts/prepackage.js` :

```javascript
// Manual copy of LanceDB binary (ncp doesn't always copy large binaries correctly)
const lancedbBinaryPath = `node_modules/@lancedb/vectordb-${target}${isWinTarget ? "-msvc" : ""}${isLinuxTarget ? "-gnu" : ""}/index.node`;
const lancedbBinaryDest = `out/node_modules/@lancedb/vectordb-${target}${isWinTarget ? "-msvc" : ""}${isLinuxTarget ? "-gnu" : ""}/index.node`;

if (fs.existsSync(lancedbBinaryPath)) {
  try {
    fs.copyFileSync(lancedbBinaryPath, lancedbBinaryDest);
    console.log(`[info] Manually copied LanceDB binary: ${lancedbBinaryDest}`);
  } catch (e) {
    console.warn(`[warn] Failed to manually copy LanceDB binary: ${e.message}`);
  }
} else {
  console.warn(`[warn] LanceDB binary not found at: ${lancedbBinaryPath}`);
}
```

### 🧪 Test

Le binaire est maintenant correctement copié pour toutes les plateformes :

- ✅ `darwin-arm64` (macOS Apple Silicon)
- ✅ `darwin-x64` (macOS Intel)
- ✅ `linux-x64` (Linux 64-bit)
- ✅ `linux-arm64` (Linux ARM64)
- ✅ `win32-x64` (Windows 64-bit)
- ✅ `win32-arm64` (Windows ARM64)

### 📝 Vérification

Pour vérifier que le binaire est présent dans un package `.vsix` :

```bash
unzip -l build/*.vsix | grep "@lancedb.*index.node"
```

Vous devriez voir :

```
extension/out/node_modules/@lancedb/vectordb-<platform>/index.node
```

---

## Fix #2 : Vérification du GUI avant packaging (2025-11-03)

### 🐛 Problème

Le script `prepackage.js` créait un dossier `gui/dist/` vide s'il n'existait pas, ce qui résultait en une extension sans interface utilisateur.

**Symptômes** :

- ❌ `command 'continue.xxx' not found`
- ❌ Extension charge indéfiniment
- ❌ Interface ne s'affiche pas

### ✅ Solution

Ajout de vérifications strictes dans `scripts/prepackage.js` :

1. Vérification que `gui/dist/` existe
2. Vérification que `gui/dist/assets/index.js` existe
3. Vérification que `gui/dist/assets/index.css` existe
4. Arrêt du script avec message d'erreur clair si un fichier manque

### 📝 Message d'erreur ajouté

```
❌ ERROR: GUI build not found!
═══════════════════════════════════════════════

The GUI (React app) must be built before packaging the extension.

Please run:
  cd gui/
  npm install
  npm run build

Or use the automated build script:
  ./scripts/build-all.sh      (Linux/macOS)
  .\scripts\build-all.ps1    (Windows)
```

---

## Scripts Créés

Pour faciliter le build, plusieurs scripts ont été créés :

### 1. **`scripts/build-all.sh`** (Linux/macOS)

Build automatisé complet avec toutes les vérifications.

### 2. **`scripts/build-all.ps1`** (Windows)

Version PowerShell du script de build.

### 3. **`scripts/verify-build.sh`**

Script de vérification du build.

### 4. Documentation

- `BUILD.md` - Documentation technique complète
- `QUICK_FIX.md` - Solution rapide
- `FIXES.md` - Ce fichier

---

## Utilisation

### Build complet (recommandé)

```bash
cd extensions/vscode/
npm run build
```

### Build manuel (old way)

```bash
# 1. Build GUI
cd gui/
npm run build

# 2. Prepackage
cd ../extensions/vscode/
npm run prepackage

# 3. Compile
npm run esbuild

# 4. Package
npm run package
```

---

## Notes Techniques

### Taille du Package

Le package final fait environ **97 MB**, ce qui inclut :

- GUI React : ~3.6 MB (index.js) + ~91 KB (index.css)
- Extension TypeScript : ~52 MB (extension.js)
- Binaire LanceDB : ~82 MB (index.node)
- Autres dépendances natives (onnxruntime, sqlite3, etc.)

### Plateformes Testées

- ✅ macOS Apple Silicon (darwin-arm64)
- ⏳ macOS Intel (darwin-x64) - À tester
- ⏳ Linux 64-bit (linux-x64) - À tester
- ⏳ Windows 64-bit (win32-x64) - À tester

---

**Dernière mise à jour** : 2025-11-03  
**Version de l'extension** : 1.3.18
