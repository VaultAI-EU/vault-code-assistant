#!/bin/bash

# Script de build complet pour VaultAI IntelliJ Extension
# Usage: ./scripts/build-all.sh [--clean]

set -e  # Exit on error

echo "🚀 VaultAI IntelliJ Extension Build Script"
echo "==========================================="
echo ""

# Parse arguments
CLEAN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --clean)
      CLEAN=true
      shift
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Usage: $0 [--clean]"
      exit 1
      ;;
  esac
done

# Get the root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INTELLIJ_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
ROOT_DIR="$( cd "$INTELLIJ_DIR/../.." && pwd )"
GUI_DIR="$ROOT_DIR/gui"

echo "📁 Directories:"
echo "  - Root: $ROOT_DIR"
echo "  - GUI: $GUI_DIR"
echo "  - IntelliJ: $INTELLIJ_DIR"
echo ""

# Step 1: Check GUI build
echo "📦 Step 1/4: Checking GUI build..."
echo "------------------------------------"

if [ ! -f "$GUI_DIR/dist/assets/index.js" ] || [ ! -f "$GUI_DIR/dist/assets/index.css" ]; then
  echo "⚠️  GUI not built. Building now..."
  cd "$GUI_DIR"
  npm run build
  echo "✅ GUI build completed"
else
  echo "✅ GUI already built"
fi
echo ""

# Step 2: Copy GUI to IntelliJ resources
echo "📦 Step 2/4: Copying GUI to IntelliJ..."
echo "----------------------------------------"
cd "$INTELLIJ_DIR"

WEBVIEW_DIR="src/main/resources/webview"

# Remove old webview (except index.html files which are specific to IntelliJ)
if [ -d "$WEBVIEW_DIR/assets" ]; then
  echo "🗑️  Removing old GUI assets..."
  rm -rf "$WEBVIEW_DIR/assets"
fi

if [ -d "$WEBVIEW_DIR/fonts" ]; then
  rm -rf "$WEBVIEW_DIR/fonts"
fi

if [ -d "$WEBVIEW_DIR/logos" ]; then
  rm -rf "$WEBVIEW_DIR/logos"
fi

# Copy new GUI
echo "📋 Copying GUI from $GUI_DIR/dist/ to $WEBVIEW_DIR/"
cp -r "$GUI_DIR/dist/assets" "$WEBVIEW_DIR/"
cp -r "$GUI_DIR/dist/fonts" "$WEBVIEW_DIR/" 2>/dev/null || echo "⚠️  No fonts directory to copy"
cp -r "$GUI_DIR/dist/logos" "$WEBVIEW_DIR/" 2>/dev/null || echo "⚠️  No logos directory to copy"

# Verify
if [ ! -f "$WEBVIEW_DIR/assets/index.js" ]; then
  echo "❌ Error: Failed to copy GUI assets"
  exit 1
fi

echo "✅ GUI copied successfully"
echo ""

# Step 3: Clean build (optional)
if [ "$CLEAN" = true ]; then
  echo "📦 Step 3/4: Cleaning old build..."
  echo "-----------------------------------"
  ./gradlew clean
  echo "✅ Clean completed"
  echo ""
else
  echo "📦 Step 3/4: Skipping clean (use --clean to force)"
  echo "---------------------------------------------------"
  echo ""
fi

# Step 4: Build plugin
echo "📦 Step 4/4: Building IntelliJ plugin..."
echo "-----------------------------------------"
./gradlew buildPlugin

echo ""
echo "🎉 Build completed successfully!"
echo "================================="
echo ""

# Find and display the ZIP file
ZIP_FILE=$(find "$INTELLIJ_DIR/build/distributions" -name "*.zip" -type f | head -n 1)
if [ -n "$ZIP_FILE" ]; then
  ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
  echo "📦 Plugin package created:"
  echo "   File: $ZIP_FILE"
  echo "   Size: $ZIP_SIZE"
  echo ""
  echo "To install:"
  echo "  1. Open IntelliJ IDEA / PyCharm"
  echo "  2. File > Settings > Plugins"
  echo "  3. Click ⚙️ (Settings) > Install Plugin from Disk..."
  echo "  4. Select: $ZIP_FILE"
  echo "  5. Restart IDE"
else
  echo "⚠️  Warning: Could not find ZIP file in build/distributions/"
fi
