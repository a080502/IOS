#!/bin/bash
# Build script for creating standalone executable
# This script creates a standalone executable that works without Python installed

echo "============================================================"
echo "   Building Standalone Executable"
echo "   Creating price_calculator"
echo "============================================================"
echo ""

# Check if Python is installed
echo "Checking Python installation..."
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo ""
    echo "============================================================"
    echo "   ERROR: Python not found!"
    echo "============================================================"
    echo ""
    echo "Python is required to build the executable."
    echo ""
    echo "Install Python from: https://www.python.org/downloads/"
    echo "Or use your package manager:"
    echo "  - Ubuntu/Debian: sudo apt install python3 python3-pip"
    echo "  - macOS: brew install python3"
    echo ""
    exit 1
fi

# Determine python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
    PIP_CMD=pip3
else
    PYTHON_CMD=python
    PIP_CMD=pip
fi

# Check if PyInstaller is installed
echo "Checking PyInstaller installation..."
if ! $PYTHON_CMD -c "import PyInstaller" &> /dev/null; then
    echo ""
    echo "============================================================"
    echo "   PyInstaller is not installed!"
    echo "============================================================"
    echo ""
    echo "Do you want to install PyInstaller now? (y/n)"
    read -p "> " INSTALL_CHOICE
    
    if [[ "$INSTALL_CHOICE" == "y" ]] || [[ "$INSTALL_CHOICE" == "Y" ]] || [[ "$INSTALL_CHOICE" == "s" ]] || [[ "$INSTALL_CHOICE" == "S" ]]; then
        echo ""
        echo "Installing PyInstaller..."
        $PIP_CMD install pyinstaller
        
        if [ $? -ne 0 ]; then
            echo ""
            echo "============================================================"
            echo "   ERROR: Installation failed!"
            echo "============================================================"
            echo ""
            echo "Try installing manually with:"
            echo "    $PIP_CMD install pyinstaller"
            echo ""
            exit 1
        fi
        
        echo ""
        echo "PyInstaller installed successfully!"
        echo ""
    else
        echo ""
        echo "To manually install PyInstaller, run:"
        echo ""
        echo "    $PIP_CMD install pyinstaller"
        echo ""
        echo "Then run this script again."
        echo ""
        exit 1
    fi
fi

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
