# Calcolatore di Ricarico e Margine per Windows
# Markup and Margin Calculator for Windows

Questo programma calcola il **ricarico (markup)** e il **margine (margin)** partendo dal prezzo di partenza (costo) e dal prezzo di arrivo (vendita).

This program calculates **markup** and **margin** based on starting price (cost) and arrival price (selling).

---

## 📋 Cosa fa il programma / What the program does

Il programma chiede:
1. **Prezzo di partenza** (il costo del prodotto)
2. **Prezzo di arrivo** (il prezzo di vendita)

E restituisce:
- **Ricarico in percentuale e valore assoluto**
- **Margine in percentuale e valore assoluto**

The program asks for:
1. **Starting price** (the cost of the product)
2. **Arrival price** (the selling price)

And returns:
- **Markup in percentage and absolute value**
- **Margin in percentage and absolute value**

---

## 🔢 Formule / Formulas

### Ricarico / Markup
- **Percentuale**: `((Prezzo Vendita - Prezzo Costo) / Prezzo Costo) × 100`
- **Percentage**: `((Selling Price - Cost Price) / Cost Price) × 100`

### Margine / Margin
- **Percentuale**: `((Prezzo Vendita - Prezzo Costo) / Prezzo Vendita) × 100`
- **Percentage**: `((Selling Price - Cost Price) / Selling Price) × 100`

---

## 💻 Come usarlo su Windows / How to use on Windows

### ⭐ Metodo 1: SENZA Python (Raccomandato) / WITHOUT Python (Recommended)

**✅ NON SERVE INSTALLARE PYTHON! / NO NEED TO INSTALL PYTHON!**

1. **Scarica l'eseguibile** / **Download the executable**:
   - Scarica il file `price_calculator.exe` dalla cartella `dist/`
   - Download the file `price_calculator.exe` from the `dist/` folder

2. **Esegui il programma** / **Run the program**:
   - Doppio click su `price_calculator.exe`
   - Double-click on `price_calculator.exe`
   - **Nessuna installazione richiesta!** / **No installation required!**

---

### Metodo 2: Con Python installato / Method 2: With Python installed

1. **Installa Python** (se non è già installato):
   - Scarica da: https://www.python.org/downloads/
   - Durante l'installazione, assicurati di selezionare "Add Python to PATH"

2. **Apri il Prompt dei comandi (CMD)** o **PowerShell**:
   - Premi `Win + R`
   - Digita `cmd` e premi Invio

3. **Naviga alla cartella del programma**:
   ```cmd
   cd C:\percorso\alla\cartella\IOS
   ```

4. **Esegui il programma**:
   ```cmd
   python price_calculator.py
   ```

### Method 2: With Python installed

1. **Install Python** (if not already installed):
   - Download from: https://www.python.org/downloads/
   - During installation, make sure to check "Add Python to PATH"

2. **Open Command Prompt (CMD)** or **PowerShell**:
   - Press `Win + R`
   - Type `cmd` and press Enter

3. **Navigate to the program folder**:
   ```cmd
   cd C:\path\to\folder\IOS
   ```

4. **Run the program**:
   ```cmd
   python price_calculator.py
   ```

---

## 📝 Esempio di utilizzo / Usage example

```
========================================================
       CALCOLATORE DI RICARICO E MARGINE
         MARKUP AND MARGIN CALCULATOR
========================================================

Inserisci il prezzo di partenza (costo):
Enter starting price (cost):
€ 100

Inserisci il prezzo di arrivo (vendita):
Enter arrival price (selling):
€ 150

========================================================
                    RISULTATI / RESULTS
========================================================

Prezzo di partenza (costo):    € 100.00
Starting price (cost):         € 100.00

Prezzo di arrivo (vendita):    € 150.00
Arrival price (selling):       € 150.00

========================================================
RICARICO / MARKUP:
========================================================
  Valore assoluto / Absolute:  € 50.00
  Percentuale / Percentage:    50.00%

========================================================
MARGINE / MARGIN:
========================================================
  Valore assoluto / Absolute:  € 50.00
  Percentuale / Percentage:    33.33%

========================================================

📝 Formule / Formulas:

   Ricarico % = ((Prezzo Vendita - Prezzo Costo) / Prezzo Costo) × 100
   Markup % = ((Selling Price - Cost Price) / Cost Price) × 100

   Margine % = ((Prezzo Vendita - Prezzo Costo) / Prezzo Vendita) × 100
   Margin % = ((Selling Price - Cost Price) / Selling Price) × 100

========================================================

Vuoi effettuare un altro calcolo? (s/n)
Do you want to perform another calculation? (y/n)
>
```

---

## 🎯 Caratteristiche / Features

✅ **Funziona senza Python installato** (eseguibile .exe standalone)
✅ Interfaccia bilingue (Italiano/Inglese)
✅ Calcolo automatico di ricarico e margine
✅ Supporto per numeri decimali (usa . o ,)
✅ Validazione input (no valori negativi)
✅ Possibilità di effettuare calcoli multipli
✅ Formattazione chiara dei risultati
✅ Spiegazione delle formule

✅ **Works without Python installed** (standalone .exe executable)
✅ Bilingual interface (Italian/English)
✅ Automatic calculation of markup and margin
✅ Support for decimal numbers (use . or ,)
✅ Input validation (no negative values)
✅ Ability to perform multiple calculations
✅ Clear results formatting
✅ Formula explanations

---

## 🆘 Risoluzione problemi / Troubleshooting

### ⭐ Soluzione più semplice / Easiest Solution
**Usa l'eseguibile standalone `price_calculator.exe` che non richiede Python!**

**Use the standalone executable `price_calculator.exe` which doesn't require Python!**

---

### ❌ "Python non è riconosciuto come comando"
**Soluzione**: Python non è installato o non è nel PATH
- Installa Python da https://www.python.org/downloads/
- Durante l'installazione, seleziona "Add Python to PATH"

### ❌ "SyntaxError" o errori strani
**Soluzione**: Versione di Python troppo vecchia
- Assicurati di avere Python 3.6 o superiore
- Controlla con: `python --version`

### ❌ Il programma si chiude subito dopo l'apertura
**Soluzione**: Esegui il programma dal Prompt dei comandi invece che con doppio click
- Segui il "Metodo 1" nelle istruzioni sopra

---

### ❌ "Python is not recognized as a command"
**Solution**: Python is not installed or not in PATH
- Install Python from https://www.python.org/downloads/
- During installation, check "Add Python to PATH"

### ❌ "SyntaxError" or strange errors
**Solution**: Python version too old
- Make sure you have Python 3.6 or higher
- Check with: `python --version`

### ❌ The program closes immediately after opening
**Solution**: Run the program from Command Prompt instead of double-clicking
- Follow "Method 1" in the instructions above

---

## 📊 Requisiti di sistema / System requirements

### Per l'eseguibile standalone (price_calculator.exe)
- **Sistema operativo**: Windows 7/8/10/11
- **Python**: ❌ NON NECESSARIO / NOT REQUIRED
- **Spazio su disco**: ~10 MB

### For standalone executable (price_calculator.exe)
- **Operating system**: Windows 7/8/10/11
- **Python**: ❌ NOT REQUIRED
- **Disk space**: ~10 MB

### Per eseguire il file Python (.py)
- **Sistema operativo**: Windows/Linux/macOS
- **Python**: 3.6 o superiore
- **Spazio su disco**: < 1 MB

### To run the Python file (.py)
- **Operating system**: Windows/Linux/macOS
- **Python**: 3.6 or higher
- **Disk space**: < 1 MB

---

## 🎓 Differenza tra Ricarico e Margine / Difference between Markup and Margin

### Ricarico / Markup
Il ricarico indica quanto viene aggiunto al costo per ottenere il prezzo di vendita.
È calcolato rispetto al **costo**.

Markup indicates how much is added to the cost to get the selling price.
It is calculated relative to the **cost**.

**Esempio**: Se compri a € 100 e vendi a € 150, il ricarico è del **50%** (hai aggiunto il 50% del costo).

**Example**: If you buy at € 100 and sell at € 150, the markup is **50%** (you added 50% of the cost).

### Margine / Margin
Il margine indica quanto guadagni rispetto al prezzo di vendita.
È calcolato rispetto al **prezzo di vendita**.

Margin indicates how much you earn relative to the selling price.
It is calculated relative to the **selling price**.

**Esempio**: Se compri a € 100 e vendi a € 150, il margine è del **33.33%** (il guadagno è il 33.33% del prezzo di vendita).

**Example**: If you buy at € 100 and sell at € 150, the margin is **33.33%** (the profit is 33.33% of the selling price).

---

## 🔧 Per Sviluppatori: Creare l'Eseguibile / For Developers: Building the Executable

Se vuoi ricreare l'eseguibile standalone da zero, segui questi passi:

If you want to rebuild the standalone executable from scratch, follow these steps:

### Su Windows / On Windows

1. **Installa Python e PyInstaller**:
   ```cmd
   pip install pyinstaller
   ```

2. **Esegui lo script di build**:
   ```cmd
   build_executable.bat
   ```

3. **L'eseguibile sarà creato in** `dist/price_calculator.exe`

### Su Linux/Mac

1. **Installa PyInstaller**:
   ```bash
   pip install pyinstaller
   ```

2. **Esegui lo script di build**:
   ```bash
   chmod +x build_executable.sh
   ./build_executable.sh
   ```

3. **L'eseguibile sarà creato in** `dist/price_calculator`

**Nota**: L'eseguibile creato su Windows funzionerà solo su Windows. L'eseguibile creato su Linux funzionerà solo su Linux.

**Note**: The executable created on Windows will only work on Windows. The executable created on Linux will only work on Linux.

---

## 📞 Note

Questo programma è stato creato per il repository iOS **a080502/IOS** come utility accessoria per calcoli commerciali.

This program was created for the iOS repository **a080502/IOS** as an accessory utility for business calculations.

---

**Buon calcolo! / Happy calculating! 🧮**
