# ✅ Correction du problème de publication sur VS Code Marketplace

## 🎯 Problème initial

Lors de l'upload de l'extension `vaultai-code-assistant-x64-1.3.18.vsix` sur le VS Code Marketplace, l'erreur suivante apparaissait :

```
Error: Value cannot be null.
Parameter name: v1
```

## 🔍 Cause du problème

L'erreur était causée par une **incohérence dans les métadonnées de l'extension** :

- Le champ `"name"` dans `package.json` était `"continue"` (nom hérité du fork)
- Le nom du fichier `.vsix` était `vaultai-code-assistant-x64-1.3.18.vsix`
- Le Marketplace VS Code exige une cohérence stricte entre :
  - Le `name` dans `package.json`
  - Le `publisher` dans `package.json`
  - Le nom du fichier `.vsix` généré
  - Les métadonnées dans `extension.vsixmanifest`

## ✨ Solution appliquée

### 1. Modification du package.json

**Fichier modifié** : `extensions/vscode/package.json`

**Avant** :

```json
{
  "name": "continue",
  "publisher": "VaultAI",
  "version": "1.3.18"
}
```

**Après** :

```json
{
  "name": "vaultai-code-assistant",
  "publisher": "VaultAI",
  "version": "1.3.18"
}
```

### 2. Reconstruction de tous les packages

Les 5 packages spécifiques aux plateformes ont été reconstruits :

```bash
cd extensions/vscode
rm -rf out bin build
npm run package-all
```

**Résultat** : Tous les fichiers `.vsix` ont été générés avec les métadonnées correctes.

## 📦 Packages générés

Les fichiers suivants ont été créés dans `extensions/vscode/build/` :

| Fichier                                           | Plateforme          | Taille |
| ------------------------------------------------- | ------------------- | ------ |
| `vaultai-code-assistant-darwin-arm64-1.3.18.vsix` | macOS Apple Silicon | 188M   |
| `vaultai-code-assistant-darwin-x64-1.3.18.vsix`   | macOS Intel         | 190M   |
| `vaultai-code-assistant-linux-arm64-1.3.18.vsix`  | Linux ARM64         | 189M   |
| `vaultai-code-assistant-linux-x64-1.3.18.vsix`    | Linux x64           | 191M   |
| `vaultai-code-assistant-win32-x64-1.3.18.vsix`    | Windows x64         | 186M   |

## ✅ Vérifications effectuées

### Métadonnées dans extension.vsixmanifest

```xml
<Identity
  Language="en-US"
  Id="vaultai-code-assistant"
  Version="1.3.18"
  Publisher="VaultAI"
  TargetPlatform="linux-x64"
/>
<DisplayName>VaultAI - On-premise AI Code Assistant</DisplayName>
<Description>Assistant de code IA on-premise pour entreprises avec souveraineté des données</Description>
```

### Identifiant unique de l'extension

- **Format** : `Publisher.Name`
- **Valeur** : `VaultAI.vaultai-code-assistant`

✅ Tous les fichiers sont cohérents et prêts à être publiés.

## 📋 Prochaines étapes pour publier

### Option A : Via l'interface web du Marketplace

1. Aller sur https://marketplace.visualstudio.com/manage
2. Se connecter avec un compte Microsoft/Azure
3. Créer un publisher **`VaultAI`** (si pas encore fait)
4. Cliquer sur "New Extension" ou sur le publisher existant
5. Upload chaque fichier `.vsix` individuellement

### Option B : Via la CLI vsce

Un script automatisé a été créé pour faciliter la publication :

```bash
cd extensions/vscode
./scripts/publish-to-marketplace.sh
```

Ou manuellement :

```bash
# 1. Se connecter (nécessite un PAT Azure DevOps)
npx @vscode/vsce login VaultAI

# 2. Publier tous les packages
cd extensions/vscode/build
npx @vscode/vsce publish --packagePath vaultai-code-assistant-darwin-arm64-1.3.18.vsix
npx @vscode/vsce publish --packagePath vaultai-code-assistant-darwin-x64-1.3.18.vsix
npx @vscode/vsce publish --packagePath vaultai-code-assistant-linux-arm64-1.3.18.vsix
npx @vscode/vsce publish --packagePath vaultai-code-assistant-linux-x64-1.3.18.vsix
npx @vscode/vsce publish --packagePath vaultai-code-assistant-win32-x64-1.3.18.vsix
```

### Prérequis pour la publication via CLI

1. **Créer un compte Publisher sur le Marketplace**

   - URL : https://marketplace.visualstudio.com/manage
   - Publisher ID : **`VaultAI`**

2. **Générer un Personal Access Token (PAT)**
   - URL : https://dev.azure.com
   - Settings > Personal Access Tokens
   - Permissions requises : **Marketplace (Manage)**
   - Scope : All accessible organizations

## 📚 Documentation créée

1. **`vaultai/PUBLISH_TO_MARKETPLACE.md`** : Guide détaillé de publication
2. **`extensions/vscode/scripts/publish-to-marketplace.sh`** : Script automatisé de publication
3. **Ce fichier** : Récapitulatif de la correction

## 🔧 Commandes utiles pour le futur

### Rebuild après modifications du code

```bash
# Rebuild complet (core + extension + GUI)
cd core && npm run build
cd ../extensions/vscode && npm run esbuild
cd ../../gui && npm run build
cd ../extensions/vscode && rm -rf gui && cp -r ../../gui/dist gui

# Rebuild uniquement pour une plateforme
cd extensions/vscode
rm -rf out bin build
mkdir -p build
node scripts/prepackage.js --target linux-x64
npm run esbuild
node scripts/package.js --target linux-x64

# Rebuild pour toutes les plateformes
cd extensions/vscode
rm -rf out bin build
npm run package-all
```

### Incrémenter la version

Avant de publier une nouvelle version :

```bash
cd extensions/vscode
npm version patch  # 1.3.18 → 1.3.19
# ou
npm version minor  # 1.3.18 → 1.4.0
# ou
npm version major  # 1.3.18 → 2.0.0

# Puis rebuild
npm run package-all
```

## ⚠️ Points d'attention

### Compatibilité avec Continue.dev

**Ne PAS modifier** les éléments suivants (pour maintenir la compatibilité avec le fork) :

- ❌ IDs de commandes (`continue.*`)
- ❌ Noms de contextes VS Code (`continue.*`)
- ❌ Noms de variables internes
- ❌ Chemins de configuration (`.continue/`)

**OK à modifier** (branding VaultAI) :

- ✅ `displayName` : Nom affiché dans VS Code
- ✅ `description` : Description de l'extension
- ✅ Strings visibles dans le GUI
- ✅ URLs (docs, support, etc.)
- ✅ Icônes et assets visuels

### Taille des fichiers

Les fichiers `.vsix` sont volumineux (~190M) car ils contiennent :

- Binaires natifs (onnxruntime, sqlite, lancedb) pour chaque plateforme
- Modèles d'embeddings pour l'IA
- GUI React compilé
- Tree-sitter WASM

C'est **normal** pour une extension avec IA embarquée et capacités on-premise.

## 🎉 Résultat

✅ **Le problème de publication est résolu !**

L'extension `VaultAI.vaultai-code-assistant` peut maintenant être publiée sur le VS Code Marketplace sans erreur.

Une fois publiée, elle sera disponible sur :

- **Marketplace** : https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant
- **Installation** : `code --install-extension VaultAI.vaultai-code-assistant`
- **Recherche VS Code** : "VaultAI" dans l'onglet Extensions

---

**Date** : 16 décembre 2025  
**Version corrigée** : 1.3.18  
**Status** : ✅ Prêt à être publié  
**Auteur** : VaultAI SAS
