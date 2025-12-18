#!/bin/bash

# Script de publication sur VS Code Marketplace
# Usage: ./scripts/publish-to-marketplace.sh [patch|minor|major|version]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VSCODE_DIR="$SCRIPT_DIR/.."
ROOT_DIR="$VSCODE_DIR/../.."

echo "🚀 Publication de VaultAI sur VS Code Marketplace"
echo "=================================================="

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier que vsce est installé
if ! command -v vsce &> /dev/null; then
    echo -e "${RED}❌ vsce n'est pas installé${NC}"
    echo "Installez-le avec : npm install -g @vscode/vsce"
    exit 1
fi

# Vérifier qu'on est sur la branche vaultai-main
CURRENT_BRANCH=$(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "vaultai-main" ]; then
    echo -e "${YELLOW}⚠️  Attention : Vous n'êtes pas sur la branche vaultai-main${NC}"
    echo "Branche actuelle : $CURRENT_BRANCH"
    read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Vérifier qu'il n'y a pas de modifications non commitées
if [ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Il y a des modifications non commitées${NC}"
    read -p "Voulez-vous continuer quand même ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Type de version
VERSION_TYPE="${1:-patch}"

echo -e "${BLUE}📦 Étape 1/5 : Rebuild complet${NC}"
echo "-----------------------------------"

# Rebuild core
echo "Building core..."
cd "$ROOT_DIR/core"
npm run build

# Rebuild GUI
echo "Building GUI..."
cd "$ROOT_DIR/gui"
npm run build

# Copy GUI to extension
echo "Copying GUI to extension..."
cd "$VSCODE_DIR"
rm -rf gui
cp -r "$ROOT_DIR/gui/dist" gui

# Rebuild extension
echo "Building VS Code extension..."
npm run esbuild

echo -e "${GREEN}✅ Build complet terminé${NC}"
echo ""

echo -e "${BLUE}📋 Étape 2/5 : Vérification du package${NC}"
echo "-----------------------------------"

# Vérifier le contenu du package
cd "$VSCODE_DIR"
vsce ls | head -20

echo ""
read -p "Le contenu du package vous semble-t-il correct ? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Publication annulée${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔢 Étape 3/5 : Versioning${NC}"
echo "-----------------------------------"

CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "Version actuelle : $CURRENT_VERSION"

if [ "$VERSION_TYPE" == "patch" ] || [ "$VERSION_TYPE" == "minor" ] || [ "$VERSION_TYPE" == "major" ]; then
    echo "Incrémentation : $VERSION_TYPE"
else
    echo "Version spécifique : $VERSION_TYPE"
fi

echo ""
read -p "Confirmer le versioning ? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Publication annulée${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔑 Étape 4/5 : Connexion au Marketplace${NC}"
echo "-----------------------------------"

# Vérifier si le PAT est dans une variable d'environnement
if [ -z "$VSCE_PAT" ]; then
    echo -e "${YELLOW}⚠️  Variable VSCE_PAT non définie${NC}"
    echo "Assurez-vous d'être connecté avec : vsce login VaultAI"
    echo "Ou définissez la variable : export VSCE_PAT=your_token"
    echo ""
    read -p "Voulez-vous vous connecter maintenant ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        vsce login VaultAI
    fi
fi

echo ""
echo -e "${BLUE}🚀 Étape 5/5 : Publication${NC}"
echo "-----------------------------------"

echo -e "${YELLOW}⚠️  Dernière confirmation avant publication !${NC}"
read -p "Publier l'extension VaultAI sur le Marketplace ? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Publication annulée${NC}"
    exit 1
fi

# Publication
echo ""
echo "Publication en cours..."

if [ -n "$VSCE_PAT" ]; then
    vsce publish "$VERSION_TYPE" -p "$VSCE_PAT"
else
    vsce publish "$VERSION_TYPE"
fi

echo ""
echo -e "${GREEN}🎉 Publication réussie !${NC}"
echo ""
echo "L'extension sera disponible dans quelques minutes sur :"
echo "https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant"
echo ""

# Afficher la nouvelle version
NEW_VERSION=$(node -p "require('./package.json').version")
echo "Version publiée : $NEW_VERSION"
echo ""

echo -e "${BLUE}📝 N'oublie pas de :${NC}"
echo "  ✅ Créer un tag Git : git tag v$NEW_VERSION"
echo "  ✅ Pusher le tag : git push origin v$NEW_VERSION"
echo "  ✅ Mettre à jour le CHANGELOG.md"
echo "  ✅ Créer une release sur GitHub"

