# 🎯 SOLUZIONE RAPIDA PER WINDOWS / QUICK SOLUTION FOR WINDOWS

## ✅ PROGRAMMA GIÀ PRONTO / READY-TO-USE PROGRAM

**Non vuoi compilare nulla? Perfetto!**  
**Don't want to build anything? Perfect!**

### 📥 Opzione 1: Scarica l'eseguibile pre-compilato / Download pre-built executable

Vai su GitHub Releases e scarica `price_calculator.exe`:

Go to GitHub Releases and download `price_calculator.exe`:

🔗 **[Download price_calculator.exe from Releases](https://github.com/a080502/IOS/releases)**

1. Vai alla pagina Releases / Go to the Releases page
2. Scarica `price_calculator.exe` / Download `price_calculator.exe`
3. Doppio click per eseguire / Double-click to run
4. **Fatto!** / **Done!**

---

### 🐍 Opzione 2: Usa Python direttamente (più semplice) / Use Python directly (easier)

Se hai Python installato, **NON serve compilare**! Usa direttamente lo script:

If you have Python installed, **NO need to build**! Use the script directly:

1. Apri il Prompt dei comandi / Open Command Prompt
2. Vai alla cartella / Go to the folder:
   ```cmd
   cd C:\percorso\alla\cartella\IOS
   ```
3. Esegui / Run:
   ```cmd
   python price_calculator.py
   ```

**Questo è il metodo più semplice!** / **This is the easiest method!**

---

### 🔧 Opzione 3: Risolvi il problema del build / Fix the build issue

**Il problema**: PyInstaller è installato ma non è nel PATH di Windows.

**The problem**: PyInstaller is installed but not in Windows PATH.

**La soluzione**: Il build script è stato aggiornato per usare `python -m PyInstaller` che funziona sempre!

**The solution**: The build script has been updated to use `python -m PyInstaller` which always works!

Ora esegui di nuovo:

Now run again:
```cmd
build_executable.bat
```

Questo dovrebbe funzionare anche se pyinstaller non è nel PATH!

This should work even if pyinstaller is not in PATH!

---

## 🆘 Risoluzione Problemi / Troubleshooting

### ❌ Problema: "pyinstaller" non è riconosciuto

**Soluzione Rapida**: Usa il file Python direttamente!

**Quick Solution**: Use the Python file directly!

```cmd
python price_calculator.py
```

### ❌ Problema: "python" non è riconosciuto

**Soluzione**: Installa Python da https://www.python.org/downloads/

**Solution**: Install Python from https://www.python.org/downloads/

Durante l'installazione, seleziona "Add Python to PATH"!

During installation, check "Add Python to PATH"!

---

## 📝 Cosa fa il programma / What the program does

Calcola automaticamente:
- **Ricarico (Markup)**: Quanto guadagno percentuale sul costo
- **Margine (Margin)**: Quanto guadagno percentuale sulla vendita

Automatically calculates:
- **Markup**: Profit percentage on cost
- **Margin**: Profit percentage on selling price

### Esempio / Example:

```
Prezzo di partenza (costo):    € 100.00
Prezzo di arrivo (vendita):    € 150.00

RICARICO / MARKUP:
  Valore assoluto:  € 50.00
  Percentuale:      50.00%

MARGINE / MARGIN:
  Valore assoluto:  € 50.00
  Percentuale:      33.33%
```

---

## 💡 Consiglio / Recommendation

**Per utenti Windows**: Usa Python direttamente (Opzione 2) - è più semplice e veloce!

**For Windows users**: Use Python directly (Option 2) - it's simpler and faster!

Non serve compilare se hai Python installato!

No need to build if you have Python installed!

---

## 📧 Serve aiuto? / Need help?

Apri un Issue su GitHub: https://github.com/a080502/IOS/issues

Open an Issue on GitHub: https://github.com/a080502/IOS/issues
