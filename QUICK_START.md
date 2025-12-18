# 🚀 QUICK START - 5 Minuti per iniziare

## Prima di iniziare

Hai bisogno di:
- ✅ Account Apple Developer (€99/anno)
- ✅ Certificato `.p12` e Provisioning Profile `.mobileprovision`
- ✅ Account su Codemagic.io (gratuito)

Non li hai ancora? → Leggi [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)

---

## ⚡ 3 Comandi per Uploadare

### 1. Personalizza Bundle ID

```bash
# Apri e modifica codemagic.yaml
nano codemagic.yaml

# Cerca e sostituisci (2 volte):
com.mynoleggioapp.app  →  com.TUAAZIENDA.TUAAPP

# Cerca e sostituisci (1 volta):
your-email@example.com  →  tua@email.com
```

### 2. Push su Git

```bash
cd /var/www/spazio/IOS

# Inizializza Git (se non fatto)
git init
git add .
git commit -m "iOS project ready for Codemagic"

# Aggiungi remote (sostituisci con il tuo URL)
git remote add origin https://github.com/TUO_USERNAME/TUO_REPO.git

# Push
git branch -M main
git push -u origin main
```

### 3. Configura Codemagic

1. Vai su **https://codemagic.io/signup**
2. Connetti il repository
3. **Add application** → Seleziona il tuo repo
4. Vai in **Settings** → **Code signing identities**
5. **Upload** il file `.p12` (+ password)
6. **Upload** il file `.mobileprovision`
7. **Save**

---

## 🎯 Build!

1. Dashboard progetto → **Start new build**
2. Branch: `main`
3. Workflow: `ios-workflow`
4. Click **Start new build**
5. Aspetta 10-15 minuti ☕
6. Download `.ipa` da **Artifacts**

**FATTO! Hai il tuo IPA! 🎉**

---

## 📱 Installa l'IPA su iPhone

### Metodo 1: TestFlight (Consigliato)
```
1. Carica IPA su App Store Connect
2. Invita tester
3. Tester scaricano app TestFlight
4. Install!
```

### Metodo 2: Diawi (Veloce)
```
1. Vai su https://www.diawi.com/
2. Upload IPA
3. Condividi link
4. Apri link su iPhone → Install
```

### Metodo 3: Apple Configurator 2
```
1. Installa Apple Configurator 2 (Mac)
2. Collega iPhone via cavo
3. Devices → [Tuo iPhone] → Apps → Add
4. Seleziona IPA → Install
```

---

## ❓ Problemi?

### Build fallita
```bash
# Controlla che tutto sia OK
./check_project.sh

# Leggi i log su Codemagic (molto dettagliati)
```

### Code signing error
- Verifica Bundle ID uguale ovunque
- Ricarica certificati su Codemagic
- Controlla che certificato non sia scaduto

### Guida completa
→ [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)

---

## 📚 File Utili

| File | Descrizione |
|------|-------------|
| [README.md](README.md) | Overview progetto |
| [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md) | **Guida completa step-by-step** |
| [CHECKLIST.md](CHECKLIST.md) | Checklist verifica pre-build |
| [check_project.sh](check_project.sh) | Script controllo automatico |

---

**Buon build! 🚀**
