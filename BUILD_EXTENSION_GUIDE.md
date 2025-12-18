# 🔧 Guide de Build de l'Extension VaultAI

## 🚨 Problème Identifié

Si vous rencontrez ces erreurs lors de l'installation de l'extension VaultAI :

- ❌ `command 'continue.viewHistory' not found`
- ❌ `command 'continue.newSession' not found`
- ❌ `command 'continue.openConfigPage' not found`
- ❌ L'extension charge indéfiniment sans afficher l'interface

**Cause principale** : Le GUI (interface React) n'a pas été construit avant de packager l'extension.

## ✅ Solution Rapide

### Pour celui qui build l'extension :

**Utilisez le nouveau script de build automatisé** :

#### Linux / macOS :

```bash
cd extensions/vscode/
./scripts/build-all.sh
```

#### Windows :

```powershell
cd extensions\vscode\
.\scripts\build-all.ps1
```

Ce script va :

1. ✅ Construire le GUI (React app)
2. ✅ Copier les fichiers nécessaires
3. ✅ Compiler le code TypeScript
4. ✅ Créer le package `.vsix`

Le fichier `.vsix` sera créé dans `extensions/vscode/build/`

### Pour ceux qui installent l'extension :

Une fois que l'extension a été buildée correctement avec le script ci-dessus, l'installation devrait fonctionner :

```bash
code --install-extension ./extensions/vscode/build/continue-*.vsix
```

## 📚 Documentation Complète

Pour plus de détails sur le processus de build, consultez :

- **`extensions/vscode/BUILD.md`** - Guide complet de build
- **`extensions/vscode/scripts/`** - Scripts de build automatisés

## 🔍 Pourquoi ce problème se produit ?

L'extension VS Code VaultAI est composée de deux parties :

1. **Le backend (extension TypeScript)** - Gère l'intégration VS Code
2. **Le GUI (app React)** - Interface utilisateur de l'assistant

Avant, le processus de build ne vérifiait pas si le GUI était construit, ce qui créait des extensions **vides** ou **incomplètes**.

### Ancien processus (❌ Problématique) :

```bash
cd extensions/vscode/
npm run prepackage  # ⚠️ Copie gui/dist/ même s'il n'existe pas !
npm run package     # ❌ Crée un .vsix incomplet
```

### Nouveau processus (✅ Correct) :

```bash
cd extensions/vscode/
./scripts/build-all.sh  # ✅ Build GUI + extension + vérifications
```

## 🛠️ Options de Build Avancées

### Build pour une plateforme spécifique :

```bash
# macOS Apple Silicon
./scripts/build-all.sh --target darwin-arm64

# macOS Intel
./scripts/build-all.sh --target darwin-x64

# Linux
./scripts/build-all.sh --target linux-x64

# Windows
./scripts/build-all.sh --target win32-x64
```

### Pre-release :

```bash
./scripts/build-all.sh --pre-release
```

### Skip GUI build (si déjà construit) :

```bash
./scripts/build-all.sh --skip-gui
```

## 🐛 Débogage

### Vérifier que le GUI est bien inclus dans le package :

```bash
# Linux / macOS
unzip -l build/*.vsix | grep -E "gui/assets/(index\.js|index\.css)"

# Windows
Expand-Archive -Path .\build\*.vsix -DestinationPath .\temp\
Get-ChildItem -Path .\temp\extension\gui\assets\
Remove-Item -Path .\temp\ -Recurse
```

Vous devriez voir :

- ✅ `extension/gui/assets/index.js`
- ✅ `extension/gui/assets/index.css`

Si ces fichiers sont absents, le GUI n'a pas été construit correctement.

### Rebuild complet :

Si vous avez des problèmes, faites un rebuild complet :

```bash
# Depuis extensions/vscode/
rm -rf build/ gui/ out/ bin/ node_modules/

# Réinstaller les dépendances
npm install

# Rebuild complet
./scripts/build-all.sh
```

## 📞 Support

Si vous rencontrez encore des problèmes après avoir suivi ce guide :

1. Vérifiez que Node.js >= 20.19.0 est installé
2. Vérifiez que npm >= 9.0.0 est installé
3. Consultez les logs de build pour les erreurs
4. Ouvrez une issue sur GitHub avec les logs

## 🎯 Checklist avant de distribuer l'extension

- [ ] Le GUI a été construit (`gui/dist/assets/index.js` existe)
- [ ] Le script `build-all` a été utilisé
- [ ] Le fichier `.vsix` a été créé dans `build/`
- [ ] Le package a été testé en local :
  ```bash
  code --install-extension ./build/*.vsix
  ```
- [ ] L'extension se charge correctement
- [ ] Les commandes `continue.*` fonctionnent
- [ ] L'interface utilisateur s'affiche

## 📝 Notes Importantes

- ⚠️ **Ne jamais** exécuter seulement `npm run package` sans avoir construit le GUI avant
- ⚠️ **Ne jamais** distribuer un `.vsix` qui n'a pas été testé localement
- ✅ **Toujours** utiliser `./scripts/build-all.sh` pour le build de production
- ✅ **Toujours** vérifier que les fichiers GUI sont dans le package

## 🔄 Workflow Recommandé

### Pour le développement :

```bash
# Terminal 1 - Watch GUI
cd gui/
npm run dev

# Terminal 2 - Watch Extension
cd extensions/vscode/
npm run esbuild-watch

# Terminal 3 - Debug dans VS Code
# Ouvrir extensions/vscode/ dans VS Code
# Appuyer sur F5
```

### Pour la distribution :

```bash
cd extensions/vscode/
./scripts/build-all.sh --target <votre-plateforme>

# Tester
code --install-extension ./build/*.vsix

# Distribuer
# Le fichier .vsix dans build/ peut être partagé
```

---

**Date de création** : $(date +%Y-%m-%d)  
**Version** : 1.0  
**Auteur** : VaultAI Team
