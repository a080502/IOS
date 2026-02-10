@echo off
REM Calcolatore di Ricarico e Margine per Windows
REM Markup and Margin Calculator for Windows

echo.
echo ========================================================
echo    Avvio Calcolatore di Ricarico e Margine
echo    Starting Markup and Margin Calculator
echo ========================================================
echo.

REM Controlla se Python è installato
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERRORE: Python non e' installato!
    echo ERROR: Python is not installed!
    echo.
    echo Scarica Python da / Download Python from:
    echo https://www.python.org/downloads/
    echo.
    echo Durante l'installazione, seleziona "Add Python to PATH"
    echo During installation, select "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

REM Esegui il calcolatore
python price_calculator.py

pause
