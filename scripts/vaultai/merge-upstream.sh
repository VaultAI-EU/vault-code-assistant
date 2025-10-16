#!/bin/bash
# VaultAI - Merge Upstream Helper Script
# Aide à fusionner les changements Continue tout en préservant les customizations VaultAI
#
# Usage: bash scripts/vaultai/merge-upstream.sh
# Ou en non-interactif: MERGE_BRANCH=main bash scripts/vaultai/merge-upstream.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  VaultAI - Merge Upstream Continue Helper${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Vérifier qu'on est sur vaultai-main
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "vaultai-main" ]; then
    echo -e "${RED}❌ Vous êtes sur la branche '$CURRENT_BRANCH'${NC}"
    echo -e "${YELLOW}   Veuillez basculer sur 'vaultai-main':${NC}"
    echo -e "${YELLOW}   git checkout vaultai-main${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Vous êtes sur la branche 'vaultai-main'${NC}"
echo ""

# Step 1: Mettre à jour main
echo -e "${BLUE}Step 1: Updating 'main' branch with upstream Continue${NC}"
echo "────────────────────────────────────────────────────────────"
git fetch upstream
git checkout main
git pull upstream/main
echo -e "${GREEN}✅ Branch 'main' updated${NC}"
echo ""

# Step 2: Retourner sur vaultai-main
echo -e "${BLUE}Step 2: Returning to 'vaultai-main'${NC}"
echo "────────────────────────────────────────────────────────────"
git checkout vaultai-main
echo ""

# Step 3: Merger main dans vaultai-main
echo -e "${BLUE}Step 3: Merging 'main' into 'vaultai-main'${NC}"
echo "────────────────────────────────────────────────────────────"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Read vaultai/VAULTAI_CHANGES.md before resolving conflicts!${NC}"
echo ""

if git merge main --no-commit --no-ff; then
    echo -e "${GREEN}✅ Merge completed without conflicts!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Run: npm run build  (to verify compilation)"
    echo "  2. Test the extension locally (F5 in VS Code)"
    echo "  3. If everything works, commit:"
    echo "     git commit -m 'Merge upstream Continue + VaultAI customizations'"
    echo "  4. Push: git push origin vaultai-main"
    echo ""
else
    echo -e "${YELLOW}⚠️  CONFLICTS DETECTED!${NC}"
    echo ""
    echo -e "${BLUE}Conflict Resolution Steps:${NC}"
    echo "  1. Open vaultai/VAULTAI_CHANGES.md to understand our customizations"
    echo "  2. Run: git status  (to see which files have conflicts)"
    echo "  3. For each conflict:"
    echo "     - Open the file in your editor"
    echo "     - Look for <<<<<<< HEAD markers"
    echo "     - Decide which version to keep (usually: keep Continue structure + VaultAI customizations)"
    echo "     - Remove the markers and test"
    echo "  4. After resolving all conflicts:"
    echo "     git add ."
    echo "     npm run build  (verify compilation)"
    echo "     (test locally)"
    echo "     git commit -m 'Merge upstream Continue + resolve VaultAI customizations'"
    echo "  5. Push: git push origin vaultai-main"
    echo ""
    echo -e "${YELLOW}If you want to abort this merge:${NC}"
    echo "     git merge --abort"
    echo ""
    exit 1
fi
