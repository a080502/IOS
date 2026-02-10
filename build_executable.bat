@echo off
REM Build script for creating standalone Windows executable
REM This script creates a price_calculator.exe that works without Python installed

echo.
echo ============================================================
echo    Building Standalone Windows Executable
echo    Creating price_calculator.exe
echo ============================================================
echo.

REM Check if Python is installed
echo Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo    ERRORE / ERROR: Python non trovato!
    echo    Python not found!
    echo ============================================================
    echo.
    echo Python e' richiesto per creare l'eseguibile.
    echo Python is required to build the executable.
    echo.
    echo Scarica Python da / Download Python from:
    echo https://www.python.org/downloads/
    echo.
    echo Durante l'installazione, seleziona "Add Python to PATH"
    echo During installation, check "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

REM Check if PyInstaller is installed
echo Checking PyInstaller installation...
python -c "import PyInstaller" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo    PyInstaller non e' installato!
    echo    PyInstaller is not installed!
    echo ============================================================
    echo.
    echo Vuoi installare PyInstaller ora? (s/n)
    echo Do you want to install PyInstaller now? (y/n)
    set /p INSTALL_CHOICE=^> 
    
    if /i "%INSTALL_CHOICE%"=="s" goto INSTALL_PYINSTALLER
    if /i "%INSTALL_CHOICE%"=="y" goto INSTALL_PYINSTALLER
    
    echo.
    echo Per installare manualmente PyInstaller, esegui:
    echo To manually install PyInstaller, run:
    echo.
    echo     pip install pyinstaller
    echo.
    echo Poi riesegui questo script.
    echo Then run this script again.
    echo.
    pause
    exit /b 1
    
    :INSTALL_PYINSTALLER
    echo.
    echo Installazione di PyInstaller in corso...
    echo Installing PyInstaller...
    pip install pyinstaller
    
    if %errorlevel% neq 0 (
        echo.
        echo ============================================================
        echo    ERRORE / ERROR: Installazione fallita!
        echo    Installation failed!
        echo ============================================================
        echo.
        echo Prova a installare manualmente con:
        echo Try installing manually with:
        echo.
        echo     pip install pyinstaller
        echo.
        pause
        exit /b 1
    )
    
    echo.
    echo PyInstaller installato con successo!
    echo PyInstaller installed successfully!
    echo.
)

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
