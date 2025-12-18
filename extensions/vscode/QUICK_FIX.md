# 🔧 Fix Rapide : Extension ne charge pas

## 🚨 Symptômes

- ❌ `command 'continue.xxx' not found`
- ❌ Extension charge indéfiniment
- ❌ Interface ne s'affiche pas

## ✅ Solution Ultra-Rapide

```bash
cd extensions/vscode/
npm run build
```

C'est tout ! Le script fera automatiquement :

1. ✅ Build du GUI (React)
2. ✅ Copie des fichiers
3. ✅ Compilation TypeScript
4. ✅ Package de l'extension

Le fichier `.vsix` sera dans `build/`

## 📝 Détails

- **Pourquoi ça arrive ?** Le GUI React n'était pas construit avant de packager l'extension
- **Documentation complète** : Voir `BUILD.md`
- **Vérifier le build** : `npm run verify-build`

## 🎯 Commandes Utiles

```bash
# Build complet (recommandé)
npm run build

# Vérifier le build
npm run verify-build

# Build pour plateforme spécifique
./scripts/build-all.sh --target linux-x64

# Build manuel (old way - non recommandé)
npm run prepackage && npm run esbuild && npm run package
```

## ⚠️ Note Importante

**Ne JAMAIS utiliser** :

```bash
npm run package  # ❌ SANS avoir build le GUI avant !
```

**Toujours utiliser** :

```bash
npm run build    # ✅ Construit tout correctement
```

---

**Pour plus d'infos** : `BUILD.md` ou `BUILD_EXTENSION_GUIDE.md` (à la racine)
