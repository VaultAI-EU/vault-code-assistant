#!/bin/bash

# 🚀 Commandes pour publier VaultAI sur VS Code Marketplace
# ============================================================
#
# Ce fichier contient toutes les commandes nécessaires.
# Copie-colle les sections dont tu as besoin !

# ============================================================
# 📋 PRÉREQUIS (déjà fait ✅)
# ============================================================

# vsce est déjà installé ✅
# Extension est déjà buildée ✅
# Packages VSIX sont déjà créés ✅


# ============================================================
# 🔑 ÉTAPE 1 : CRÉER LE COMPTE ÉDITEUR
# ============================================================

echo "1. Va sur : https://marketplace.visualstudio.com/manage"
echo "2. Connecte-toi avec Microsoft"
echo "3. Crée un Publisher avec ID : 'VaultAI'"
echo ""
echo "Appuie sur Entrée quand c'est fait..."
read


# ============================================================
# 🔐 ÉTAPE 2 : CRÉER LE TOKEN
# ============================================================

echo "1. Va sur : https://dev.azure.com"
echo "2. User Settings → Personal Access Tokens → New Token"
echo "3. Name: 'VaultAI Publishing'"
echo "4. Scope: Marketplace → Manage"
echo "5. COPIE LE TOKEN !"
echo ""
echo "Appuie sur Entrée quand tu as copié le token..."
read


# ============================================================
# 🔗 ÉTAPE 3 : SE CONNECTER
# ============================================================

echo "🔗 Connexion à vsce..."
vsce login VaultAI

# Si ça ne marche pas, tu peux aussi faire :
# vsce login VaultAI -p YOUR_TOKEN_HERE


# ============================================================
# 🚀 ÉTAPE 4 : PUBLIER (OPTION 1 - AUTOMATIQUE)
# ============================================================

echo ""
echo "🚀 Publication avec le script automatisé..."
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode
./scripts/publish-to-marketplace.sh patch

# Ou pour une version mineure :
# ./scripts/publish-to-marketplace.sh minor

# Ou pour une version majeure :
# ./scripts/publish-to-marketplace.sh major


# ============================================================
# 🚀 ÉTAPE 4 : PUBLIER (OPTION 2 - MANUELLE)
# ============================================================

# Si tu préfères faire manuellement :
cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode

# Publier la version actuelle (1.3.18)
vsce publish

# Ou publier en incrémentant la version :
# vsce publish patch   # 1.3.18 → 1.3.19
# vsce publish minor   # 1.3.18 → 1.4.0
# vsce publish major   # 1.3.18 → 2.0.0


# ============================================================
# ✅ VÉRIFICATION
# ============================================================

echo ""
echo "✅ Publication terminée !"
echo ""
echo "Ton extension sera disponible dans quelques minutes sur :"
echo "https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant"
echo ""


# ============================================================
# 📝 APRÈS PUBLICATION
# ============================================================

# Créer un tag Git pour la version
NEW_VERSION=$(cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode && node -p "require('./package.json').version")
echo "Créer un tag Git : git tag v$NEW_VERSION"
echo "Pusher le tag : git push origin v$NEW_VERSION"


# ============================================================
# 🔄 MISES À JOUR FUTURES
# ============================================================

# Pour publier une mise à jour :
# cd /Users/hugodorus/VaultAI/dev/vault-code-assistant/extensions/vscode
# ./scripts/publish-to-marketplace.sh patch


# ============================================================
# 🆘 DÉPANNAGE
# ============================================================

# Si erreur "Publisher not found" :
vsce login VaultAI

# Si erreur "Token missing" :
vsce publish -p YOUR_TOKEN_HERE

# Vérifier le contenu du package avant publication :
vsce ls

# Tester le package localement :
vsce package
code --install-extension vaultai-code-assistant-1.3.18.vsix --force

