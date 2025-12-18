#!/bin/bash

# Script de vérification du build de l'extension VaultAI
# Usage: ./scripts/verify-build.sh [path/to/vsix]

set -e

echo "🔍 VaultAI Extension Build Verification"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VSCODE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
ROOT_DIR="$( cd "$VSCODE_DIR/../.." && pwd )"
GUI_DIR="$ROOT_DIR/gui"

# Function to check if file exists
check_file() {
  local file=$1
  local name=$2
  
  if [ -f "$file" ]; then
    echo -e "${GREEN}✅${NC} $name exists"
    return 0
  else
    echo -e "${RED}❌${NC} $name NOT FOUND"
    return 1
  fi
}

# Function to check if directory exists and has content
check_dir() {
  local dir=$1
  local name=$2
  
  if [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
    echo -e "${GREEN}✅${NC} $name exists and has content"
    return 0
  else
    echo -e "${RED}❌${NC} $name NOT FOUND or EMPTY"
    return 1
  fi
}

ERRORS=0

echo "📦 Checking GUI build..."
echo "------------------------"
check_file "$GUI_DIR/dist/assets/index.js" "GUI index.js" || ((ERRORS++))
check_file "$GUI_DIR/dist/assets/index.css" "GUI index.css" || ((ERRORS++))
echo ""

echo "📦 Checking VSCode extension files..."
echo "--------------------------------------"
check_dir "$VSCODE_DIR/gui" "VSCode GUI directory" || ((ERRORS++))
check_file "$VSCODE_DIR/gui/assets/index.js" "VSCode GUI index.js" || ((ERRORS++))
check_file "$VSCODE_DIR/gui/assets/index.css" "VSCode GUI index.css" || ((ERRORS++))
echo ""

echo "📦 Checking build output..."
echo "---------------------------"
if [ -d "$VSCODE_DIR/build" ]; then
  VSIX_COUNT=$(find "$VSCODE_DIR/build" -name "*.vsix" -type f 2>/dev/null | wc -l)
  if [ "$VSIX_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅${NC} Found $VSIX_COUNT .vsix file(s) in build/"
    
    # Check the contents of the first VSIX
    VSIX_FILE=$(find "$VSCODE_DIR/build" -name "*.vsix" -type f | head -n 1)
    echo ""
    echo "🔍 Inspecting VSIX: $(basename $VSIX_FILE)"
    echo "----------------------------------------"
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    
    # Extract VSIX (it's a ZIP file)
    unzip -q "$VSIX_FILE" -d "$TEMP_DIR"
    
    # Check critical files in the VSIX
    check_file "$TEMP_DIR/extension/gui/assets/index.js" "VSIX GUI index.js" || ((ERRORS++))
    check_file "$TEMP_DIR/extension/gui/assets/index.css" "VSIX GUI index.css" || ((ERRORS++))
    check_file "$TEMP_DIR/extension/out/extension.js" "VSIX extension.js" || ((ERRORS++))
    
    # Check file sizes
    if [ -f "$TEMP_DIR/extension/gui/assets/index.js" ]; then
      SIZE=$(stat -f%z "$TEMP_DIR/extension/gui/assets/index.js" 2>/dev/null || stat -c%s "$TEMP_DIR/extension/gui/assets/index.js" 2>/dev/null)
      SIZE_KB=$((SIZE / 1024))
      if [ "$SIZE_KB" -lt 100 ]; then
        echo -e "${YELLOW}⚠️${NC}  Warning: index.js is only ${SIZE_KB}KB (might be incomplete)"
        ((ERRORS++))
      else
        echo -e "${GREEN}✅${NC} index.js size: ${SIZE_KB}KB"
      fi
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
  else
    echo -e "${RED}❌${NC} No .vsix files found in build/"
    ((ERRORS++))
  fi
else
  echo -e "${RED}❌${NC} build/ directory not found"
  ((ERRORS++))
fi
echo ""

# Summary
echo "========================================"
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed!${NC}"
  echo ""
  echo "The extension appears to be built correctly."
  echo "You can install it with:"
  echo "  code --install-extension $VSIX_FILE"
  exit 0
else
  echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
  echo ""
  echo "The extension build is incomplete or incorrect."
  echo ""
  echo "To fix this, run:"
  echo "  cd $VSCODE_DIR"
  echo "  ./scripts/build-all.sh"
  echo ""
  echo "For more information, see:"
  echo "  $VSCODE_DIR/BUILD.md"
  exit 1
fi
