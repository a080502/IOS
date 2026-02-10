#!/bin/bash
# Build script for creating standalone Windows executable
# This script creates a price_calculator.exe that works without Python installed

echo "============================================================"
echo "   Building Standalone Windows Executable"
echo "   Creating price_calculator.exe"
echo "============================================================"
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf build dist price_calculator.spec

# Build the executable
echo ""
echo "Building executable with PyInstaller..."
pyinstaller \
    --onefile \
    --name "price_calculator" \
    --console \
    --clean \
    --noconfirm \
    price_calculator.py

# Check if build was successful
if [ -f "dist/price_calculator" ] || [ -f "dist/price_calculator.exe" ]; then
    echo ""
    echo "============================================================"
    echo "   ✅ BUILD SUCCESSFUL!"
    echo "============================================================"
    echo ""
    echo "Executable created in dist/ folder"
    echo ""
    echo "To distribute:"
    echo "  1. Copy the executable from dist/ to any PC"
    echo "  2. Double-click to run (no Python needed!)"
    echo ""
else
    echo ""
    echo "============================================================"
    echo "   ❌ BUILD FAILED"
    echo "============================================================"
    echo ""
    exit 1
fi
