#!/bin/bash

# VaultAI - Rebuild Script for JetBrains Extension
# This script rebuilds the entire JetBrains plugin with VaultAI branding

set -e  # Exit on error

PROJECT_ROOT="/Users/hugodorus/VaultAI/dev/vault-code-assistant"

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "🔧 VaultAI - Rebuild JetBrains Extension"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Step 1: Build GUI
echo "1️⃣  Building GUI with VaultAI branding..."
cd "$PROJECT_ROOT/gui"
npm run build
echo "✅ GUI built successfully"
echo ""

# Step 2: Copy GUI to JetBrains
echo "2️⃣  Copying GUI to JetBrains webview..."
cd "$PROJECT_ROOT"
rm -rf extensions/intellij/src/main/resources/webview/*
cp -r gui/dist/* extensions/intellij/src/main/resources/webview/
echo "✅ GUI copied to JetBrains"
echo ""

# Step 3: Build binary (core)
echo "3️⃣  Building binary (core) for macOS..."
cd "$PROJECT_ROOT/binary"
npm run build -- --os darwin
echo "✅ Binary built successfully"
echo ""

# Step 4: Apply VaultAI branding
echo "4️⃣  Applying VaultAI branding..."
cd "$PROJECT_ROOT"
node scripts/vaultai/apply-branding-intellij.js
echo "✅ VaultAI branding applied"
echo ""

# Step 5: Build JetBrains plugin
echo "5️⃣  Building JetBrains plugin..."
cd "$PROJECT_ROOT/extensions/intellij"
./gradlew clean buildPlugin
echo "✅ JetBrains plugin built successfully"
echo ""

# Final output
PLUGIN_PATH="$PROJECT_ROOT/extensions/intellij/build/distributions/vaultai-code-assistant-intellij-1.0.0-vaultai.zip"

echo "═══════════════════════════════════════════════════════════════════"
echo "✅ BUILD COMPLETE!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "📦 Plugin location:"
echo "   $PLUGIN_PATH"
echo ""
echo "📥 To install:"
echo "   1. IntelliJ: Settings → Plugins → ⚙️  → Install Plugin from Disk..."
echo "   2. Select: $PLUGIN_PATH"
echo "   3. Restart IntelliJ"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""


