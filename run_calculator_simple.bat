@echo off
REM Esegui direttamente il calcolatore senza compilare
REM Run the calculator directly without building

echo.
echo ============================================================
echo    CALCOLATORE DI RICARICO E MARGINE
echo    MARKUP AND MARGIN CALCULATOR
echo ============================================================
echo.
echo Avvio del programma... / Starting the program...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo    ERRORE / ERROR: Python non trovato!
    echo    Python not found!
    echo ============================================================
    echo.
    echo Installa Python da / Install Python from:
    echo https://www.python.org/downloads/
    echo.
    echo Durante l'installazione, seleziona "Add Python to PATH"
    echo During installation, check "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

REM Run the calculator
python price_calculator.py

REM Keep window open if there was an error
if %errorlevel% neq 0 (
    echo.
    echo Si e' verificato un errore.
    echo An error occurred.
    pause
)
