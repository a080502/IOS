@echo off
REM Build script for creating standalone Windows executable
REM This script creates a price_calculator.exe that works without Python installed

echo.
echo ============================================================
echo    Building Standalone Windows Executable
echo    Creating price_calculator.exe
echo ============================================================
echo.

REM Clean previous builds
echo Cleaning previous builds...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist price_calculator.spec del /f price_calculator.spec

REM Build the executable
echo.
echo Building executable with PyInstaller...
pyinstaller --onefile --name "price_calculator" --console --clean --noconfirm price_calculator.py

REM Check if build was successful
if exist "dist\price_calculator.exe" (
    echo.
    echo ============================================================
    echo    BUILD SUCCESSFUL!
    echo ============================================================
    echo.
    echo Executable created at: dist\price_calculator.exe
    echo.
    echo To distribute:
    echo   1. Copy dist\price_calculator.exe to any Windows PC
    echo   2. Double-click to run (no Python needed!)
    echo.
) else (
    echo.
    echo ============================================================
    echo    BUILD FAILED
    echo ============================================================
    echo.
    pause
    exit /b 1
)

pause
