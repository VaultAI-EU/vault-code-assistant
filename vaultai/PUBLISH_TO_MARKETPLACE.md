# 📦 Guide de Publication sur VS Code Marketplace

Ce guide détaille les étapes pour publier l'extension VaultAI sur le VS Code Marketplace.

## 📋 Prérequis

- ✅ Extension buildée et testée localement
- ✅ `vsce` installé (`npm install -g @vscode/vsce`)
- ⏳ Compte éditeur sur VS Code Marketplace
- ⏳ Personal Access Token (PAT) Azure DevOps

---

## 🎯 Étape 1 : Créer un compte éditeur

### 1.1 Créer une organisation Azure DevOps

1. Va sur [https://dev.azure.com](https://dev.azure.com)
2. Connecte-toi avec ton compte Microsoft (ou crée-en un)
3. Clique sur **"Create new organization"**
4. Nomme ton organisation : `VaultAI` (ou `vaultai-sas`)
5. Choisis une région (Europe recommandé)

### 1.2 Créer un éditeur sur le Marketplace

1. Va sur [https://marketplace.visualstudio.com/manage](https://marketplace.visualstudio.com/manage)
2. Connecte-toi avec le **même compte Microsoft**
3. Clique sur **"Create Publisher"**
4. Remplis les informations :
   - **Publisher ID**: `VaultAI` (doit correspondre au champ `publisher` dans `package.json`)
   - **Display Name**: `VaultAI`
   - **Description**: `Solutions d'IA on-premise pour entreprises`
   - **Website**: `https://vaultai.eu`

> ⚠️ **Important** : Le `Publisher ID` doit être **exactement** `VaultAI` comme dans ton `package.json` !

---

## 🔑 Étape 2 : Générer un Personal Access Token (PAT)

### 2.1 Créer le token

1. Va sur [https://dev.azure.com](https://dev.azure.com)
2. Clique sur ton profil (en haut à droite) → **"Personal access tokens"**
3. Clique sur **"+ New Token"**
4. Configure le token :

   - **Name**: `VaultAI Extension Publishing`
   - **Organization**: Sélectionne ton organisation (`VaultAI`)
   - **Expiration**: 1 an (ou personnalisé)
   - **Scopes**: Sélectionne **"Custom defined"**
   - Coche uniquement : **Marketplace** → **Manage** (read, acquire, publish, and manage extensions)

5. Clique sur **"Create"**
6. **COPIE LE TOKEN IMMÉDIATEMENT** (tu ne pourras plus le voir après !)

### 2.2 Sauvegarder le token de manière sécurisée

```bash
# Option 1 : Utiliser vsce pour stocker le token
vsce login VaultAI

# Option 2 : Créer une variable d'environnement
echo "export VSCE_PAT=your_token_here" >> ~/.zshrc
source ~/.zshrc
```

> ⚠️ **Ne commit JAMAIS le token dans Git !**

---

## 🚀 Étape 3 : Publier l'extension

### 3.1 Vérification finale

Avant de publier, vérifie que tout est OK :

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode

# Vérifie le package.json
vsce ls
```

### 3.2 Rebuild complet (si besoin)

```bash
# Depuis la racine du projet
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant

# Rebuild tout
npm run rebuild-all  # ou utilise les commandes manuelles ci-dessous

# Rebuild manuel :
cd core && npm run build
cd ../gui && npm run build
cd ../extensions/vscode && rm -rf gui && cp -r ../../gui/dist gui
cd ../extensions/vscode && npm run esbuild
```

### 3.3 Publier sur le Marketplace

```bash
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode

# Première publication
vsce publish

# Ou spécifie le token directement
vsce publish -p YOUR_TOKEN_HERE
```

### 3.4 Publier une mise à jour (versions futures)

```bash
# Incrémenter la version patch (1.3.18 → 1.3.19)
vsce publish patch

# Incrémenter la version minor (1.3.18 → 1.4.0)
vsce publish minor

# Incrémenter la version major (1.3.18 → 2.0.0)
vsce publish major

# Ou spécifier manuellement une version
vsce publish 1.4.0
```

---

## ✅ Étape 4 : Vérification après publication

### 4.1 Vérifier sur le Marketplace

1. Va sur [https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant](https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant)
2. Vérifie que :
   - Le titre est correct : **"VaultAI - On-premise AI Code Assistant"**
   - L'icône s'affiche correctement
   - La description est claire
   - Les captures d'écran sont présentes (ajoute-les dans le README.md)

### 4.2 Installer depuis le Marketplace

```bash
# Désinstalle la version locale
code --uninstall-extension VaultAI.vaultai-code-assistant

# Installe depuis le Marketplace
code --install-extension VaultAI.vaultai-code-assistant
```

---

## 📊 Gestion des versions

### Workflow recommandé

1. **Développement** : Branche `vaultai-main`
2. **Test local** : F5 dans VS Code
3. **Build complet** : `npm run package-all`
4. **Test du VSIX** : Installer le `.vsix` localement
5. **Publication** : `vsce publish`

### Versioning

- **Patch** (1.3.18 → 1.3.19) : Corrections de bugs
- **Minor** (1.3.18 → 1.4.0) : Nouvelles fonctionnalités mineures
- **Major** (1.3.18 → 2.0.0) : Breaking changes

---

## 🔧 Dépannage

### Erreur : "Publisher VaultAI not found"

```bash
# Se connecter avec le bon éditeur
vsce login VaultAI
```

### Erreur : "Personal Access Token is missing"

```bash
# Publier avec le token
vsce publish -p YOUR_TOKEN_HERE
```

### Erreur : "Extension size exceeds limit"

Les extensions VS Code ont une limite de **~200 MB**. Si nécessaire :

```bash
# Vérifier la taille
du -sh build/*.vsix

# Le package actuel fait ~190 MB, c'est OK
```

### Erreur : "Version already exists"

```bash
# Incrémente la version dans package.json
npm version patch  # ou minor, ou major
vsce publish
```

---

## 📚 Ressources

- [Documentation officielle vsce](https://github.com/microsoft/vscode-vsce)
- [Publishing Extensions](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
- [Marketplace FAQ](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#common-questions)

---

## 🎉 Félicitations !

Une fois publié, ton extension sera disponible pour des millions d'utilisateurs VS Code ! 🚀

N'oublie pas de :

- ✅ Ajouter des captures d'écran dans le README
- ✅ Rédiger une belle description
- ✅ Ajouter un CHANGELOG.md
- ✅ Mettre à jour la documentation
