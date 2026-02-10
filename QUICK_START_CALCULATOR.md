# 🚀 AVVIO RAPIDO / QUICK START

> **⚡ METODO PIÙ SEMPLICE PER WINDOWS / EASIEST METHOD FOR WINDOWS**:  
> Basta fare doppio click su `run_calculator_simple.bat` oppure eseguire `python price_calculator.py`  
> Just double-click `run_calculator_simple.bat` or run `python price_calculator.py`  
> **Nessuna compilazione necessaria! / No build needed!**

---

## ✅ FUNZIONA SENZA PYTHON! / WORKS WITHOUT PYTHON!

### Per Utenti Windows / For Windows Users

**NON SERVE INSTALLARE NULLA!** / **NO INSTALLATION NEEDED!**

1. **Scarica** / **Download**: `price_calculator.exe` dalla cartella `dist/`
2. **Doppio click** per eseguire / **Double-click** to run
3. **Fatto!** / **Done!**

---

## 🔨 Per ricostruire l'eseguibile / To rebuild the executable

### Su Windows / On Windows:
```cmd
build_executable.bat
```
Lo script installerà automaticamente PyInstaller se necessario!
The script will automatically install PyInstaller if needed!

### Su Linux/Mac:
```bash
chmod +x build_executable.sh
./build_executable.sh
```
Lo script installerà automaticamente PyInstaller se necessario!
The script will automatically install PyInstaller if needed!

L'eseguibile sarà in `dist/price_calculator.exe` (Windows) o `dist/price_calculator` (Linux/Mac)

The executable will be in `dist/price_calculator.exe` (Windows) or `dist/price_calculator` (Linux/Mac)

---

## 📖 Documentazione completa / Full documentation

Vedi `PRICE_CALCULATOR_README.md` per istruzioni dettagliate.

See `PRICE_CALCULATOR_README.md` for detailed instructions.

---

## ❓ Come funziona / How it works

Il programma calcola:
- **Ricarico** (markup): `((vendita - costo) / costo) × 100`
- **Margine** (margin): `((vendita - costo) / vendita) × 100`

The program calculates:
- **Markup**: `((selling - cost) / cost) × 100`
- **Margin**: `((selling - cost) / selling) × 100`

**Esempio / Example:**
- Costo / Cost: € 100
- Vendita / Selling: € 150
- Ricarico / Markup: 50% (€ 50)
- Margine / Margin: 33.33% (€ 50)
