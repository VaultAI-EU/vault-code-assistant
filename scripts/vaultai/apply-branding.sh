#!/bin/bash
# VaultAI Branding Application Script
# Applique le branding VaultAI à l'extension VS Code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🎨 Applying VaultAI branding to VS Code extension..."
echo ""

# Exécuter le script Node.js
cd "$PROJECT_ROOT"
node scripts/vaultai/apply-branding.js

echo ""
echo "✨ VaultAI branding successfully applied!"
echo ""
echo "📋 Changes made:"
echo "  ✅ displayName updated to: VaultAI - On-premise AI Code Assistant"
echo "  ✅ description updated"
echo "  ✅ publisher changed to: VaultAI"
echo "  ✅ author changed to: VaultAI SAS"
echo "  ✅ icon points to VaultAI logo"
echo "  ✅ repository, bugs, homepage updated to VaultAI URLs"
echo "  ✅ keywords updated"
echo ""
echo "🔒 Preserved:"
echo "  ✅ All Continue command IDs (continue.*) remain unchanged"
echo "  ✅ All extension logic remains intact"
echo "  ✅ Fully compatible with Continue upstream merges"
echo ""
echo "To revert branding and restore Continue defaults:"
echo "  git checkout extensions/vscode/package.json"
echo ""
