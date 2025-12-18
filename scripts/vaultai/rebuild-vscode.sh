#!/bin/bash

# VaultAI - Rebuild Script for VS Code Extension
# This script rebuilds the entire VS Code extension with VaultAI branding

set -e  # Exit on error

PROJECT_ROOT="/Users/hugodorus/VaultAI/dev/vault-code-assistant"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "🔧 VaultAI - Rebuild VS Code Extension"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Step 1: Build Core
echo "1️⃣  Building Core..."
cd "$PROJECT_ROOT/core"
npm run build
echo "✅ Core built successfully"
echo ""

# Step 2: Build GUI
echo "2️⃣  Building GUI with VaultAI branding..."
cd "$PROJECT_ROOT/gui"
npm run build
echo "✅ GUI built successfully"
echo ""

# Step 3: Copy GUI to VS Code extension
echo "3️⃣  Copying GUI to VS Code extension..."
cd "$PROJECT_ROOT/extensions/vscode"
rm -rf gui
cp -r ../../gui/dist gui
echo "✅ GUI copied to VS Code extension"
echo ""

# Step 4: Apply VaultAI branding
echo "4️⃣  Applying VaultAI branding..."
cd "$PROJECT_ROOT"
node scripts/vaultai/apply-branding.js
echo "✅ VaultAI branding applied"
echo ""

# Step 5: Build VS Code extension
echo "5️⃣  Building VS Code extension..."
cd "$PROJECT_ROOT/extensions/vscode"
npm run esbuild
echo "✅ VS Code extension built successfully"
echo ""

# Final output
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ BUILD COMPLETE!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "🔄 To test in VS Code:"
echo "   1. Open VS Code"
echo "   2. Press F5 to start debugging (or use Command Palette: 'Developer: Reload Window')"
echo ""
echo "📦 To package as .vsix:"
echo "   cd extensions/vscode"
echo "   npx @vscode/vsce@latest package --no-dependencies"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""

