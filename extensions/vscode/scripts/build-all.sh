#!/bin/bash

# Script de build complet pour VaultAI VSCode Extension
# Usage: ./scripts/build-all.sh [--target <platform-arch>] [--pre-release]

set -e  # Exit on error

echo "🚀 VaultAI Extension Build Script"
echo "=================================="
echo ""

# Parse arguments
TARGET=""
PRE_RELEASE=""
SKIP_GUI=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --pre-release)
      PRE_RELEASE="--pre-release"
      shift
      ;;
    --skip-gui)
      SKIP_GUI=true
      shift
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Usage: $0 [--target <platform-arch>] [--pre-release] [--skip-gui]"
      exit 1
      ;;
  esac
done

# Get the root directory (3 levels up from scripts/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VSCODE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
ROOT_DIR="$( cd "$VSCODE_DIR/../.." && pwd )"
GUI_DIR="$ROOT_DIR/gui"

echo "📁 Directories:"
echo "  - Root: $ROOT_DIR"
echo "  - GUI: $GUI_DIR"
echo "  - VSCode: $VSCODE_DIR"
echo ""

# Step 1: Build the GUI (React app)
if [ "$SKIP_GUI" = false ]; then
  echo "📦 Step 1/4: Building GUI (React app)..."
  echo "--------------------------------------"
  cd "$GUI_DIR"
  
  # Check if dist exists and has content
  if [ -d "dist" ] && [ "$(ls -A dist 2>/dev/null)" ]; then
    echo "⚠️  Warning: gui/dist already exists"
    read -p "Do you want to rebuild it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "🗑️  Cleaning old build..."
      rm -rf dist
      echo "🔨 Building GUI..."
      npm run build
    else
      echo "✅ Using existing GUI build"
    fi
  else
    echo "🔨 Building GUI..."
    npm run build
  fi
  
  # Verify the build was successful
  if [ ! -f "dist/assets/index.js" ]; then
    echo "❌ Error: GUI build failed - dist/assets/index.js not found"
    exit 1
  fi
  
  if [ ! -f "dist/assets/index.css" ]; then
    echo "❌ Error: GUI build failed - dist/assets/index.css not found"
    exit 1
  fi
  
  echo "✅ GUI build completed successfully"
  echo ""
else
  echo "⏭️  Skipping GUI build (--skip-gui flag)"
  echo ""
fi

# Step 2: Run prepackage script
echo "📦 Step 2/4: Running prepackage script..."
echo "--------------------------------------"
cd "$VSCODE_DIR"

if [ -n "$TARGET" ]; then
  echo "🎯 Target platform: $TARGET"
  node scripts/prepackage.js --target "$TARGET"
else
  echo "🎯 Auto-detecting platform..."
  node scripts/prepackage.js
fi

echo "✅ Prepackage completed"
echo ""

# Step 3: Compile TypeScript
echo "📦 Step 3/4: Compiling TypeScript..."
echo "--------------------------------------"
npm run esbuild
echo "✅ TypeScript compilation completed"
echo ""

# Step 4: Package the extension
echo "📦 Step 4/4: Packaging extension..."
echo "--------------------------------------"

if [ -n "$TARGET" ]; then
  node scripts/package.js --target "$TARGET" $PRE_RELEASE
else
  node scripts/package.js $PRE_RELEASE
fi

echo ""
echo "🎉 Build completed successfully!"
echo "=================================="
echo ""

# Find and display the VSIX file
VSIX_FILE=$(find "$VSCODE_DIR/build" -name "*.vsix" -type f | head -n 1)
if [ -n "$VSIX_FILE" ]; then
  VSIX_SIZE=$(du -h "$VSIX_FILE" | cut -f1)
  echo "📦 Extension package created:"
  echo "   File: $VSIX_FILE"
  echo "   Size: $VSIX_SIZE"
  echo ""
  echo "To install: code --install-extension $VSIX_FILE"
else
  echo "⚠️  Warning: Could not find VSIX file in build directory"
fi
