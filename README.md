# MyNoleggio iOS App - Setup Rapido Codemagic 🚀

## ✅ Stato Progetto

Il progetto è **pronto per essere compilato su Codemagic**! 

```
✓ Progetto Xcode configurato
✓ 25 file Swift
✓ codemagic.yaml configurato
✓ Assets e icone presenti
✓ Info.plist configurato
```

---

## 🎯 3 Passi per Creare l'IPA

### 1️⃣ Carica su Git (GitHub/GitLab/Bitbucket)

```bash
# Se non hai ancora inizializzato git:
git init
git add .
git commit -m "Initial iOS project"
git branch -M main
git remote add origin https://github.com/TUO_USERNAME/TUO_REPO.git
git push -u origin main
```

### 2️⃣ Configura Codemagic

1. Vai su https://codemagic.io/signup
2. **Add application** → Connetti il tuo repository
3. Codemagic rileverà automaticamente `codemagic.yaml`
4. **Settings** → **Code signing identities**:
   - Carica certificato `.p12` 
   - Carica provisioning profile `.mobileprovision`

### 3️⃣ Avvia Build

1. Click **Start new build**
2. Seleziona branch: `main`
3. Seleziona workflow: `ios-workflow`
4. Aspetta 10-15 minuti ☕
5. Scarica `.ipa` da **Artifacts**

---

## 📝 Cosa Devi Modificare

Prima di buildare, personalizza:

### ✏️ Bundle ID (obbligatorio)

Cambia `com.mynoleggioapp.app` con il tuo in:
- [`codemagic.yaml`](codemagic.yaml) (righe 8 e 12)
- `MyNoleggioApp.xcodeproj/project.pbxproj` (cerca `PRODUCT_BUNDLE_IDENTIFIER`)

### ✉️ Email di notifica

In [`codemagic.yaml`](codemagic.yaml) (riga ~64):
```yaml
recipients:
  - tua.email@example.com  # <-- CAMBIA QUI
```

---

## 🔐 Certificati Apple (richiesti)

**Hai bisogno di**:
- Account Apple Developer (€99/anno)
- Certificato Distribution (file `.p12`)
- Provisioning Profile (file `.mobileprovision`)

**📖 Guida completa**: [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)

---

## 🛠️ Struttura Progetto

```
IOS/
├── codemagic.yaml              ⭐ Config build Codemagic
├── CODEMAGIC_SETUP.md          📚 Guida completa step-by-step
├── check_project.sh            🔍 Script verifica progetto
├── ExportOptions.plist         📦 Opzioni export IPA
├── MyNoleggioApp.xcodeproj/    📱 Progetto Xcode
└── MyNoleggioApp/              💻 Codice Swift
    ├── App.swift               🎯 Entry point
    ├── Features/               🚀 Features dell'app
    │   ├── Login/              🔐 Login & PIN
    │   ├── Clients/            👥 Gestione clienti
    │   ├── Rentals/            📋 Gestione noleggi
    │   ├── BarcodeScanner/     📷 Scanner barcode
    │   └── ServerSetup/        ⚙️ Config server
    ├── Models/                 📊 Data models
    ├── Networking/             🌐 API client
    ├── Security/               🔒 Biometrics & keychain
    ├── Session/                ⏱️ Sessione & heartbeat
    └── Notifications/          🔔 Notifiche push
```

---

## 🚀 Comandi Rapidi

```bash
# Verifica configurazione progetto
./check_project.sh

# Build locale (richiede Mac con Xcode)
xcodebuild -project MyNoleggioApp.xcodeproj \
           -scheme MyNoleggioApp \
           -sdk iphoneos \
           -configuration Release \
           archive -archivePath build/MyNoleggioApp.xcarchive
```

---

## 📊 Requisiti Sistema

| Componente | Versione |
|------------|----------|
| iOS Target | 17.0+ |
| Xcode | 15.2+ |
| Swift | 5.9+ |
| Codemagic Instance | mac_mini_m1 |

---

## 🆘 Problemi Comuni

### ❌ "Code signing error"
**Soluzione**: Verifica che bundle ID corrisponda in tutti i file e che i certificati siano validi

### ❌ "Scheme not found"
**Soluzione**: Verifica che lo scheme sia condiviso in Xcode (Edit Scheme → Shared checkbox)

### ❌ "Device not registered"
**Soluzione**: Aggiungi UDID device al portale Apple e rigenera provisioning profile

**📖 Troubleshooting completo**: [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)

---

## 📚 Documentazione

- **Setup completo**: [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md) - Guida passo-passo
- **Build info**: [README_BUILD.md](README_BUILD.md) - Info generali build
- **Codemagic Docs**: https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/

---

## 💰 Costi

| Servizio | Piano | Costo |
|----------|-------|-------|
| Apple Developer | Standard | €99/anno ⚠️ **Obbligatorio** |
| Codemagic | Free | Gratis (500 min build/mese) |
| Codemagic | Pro | $49/mese (build illimitati) |

---

## ✨ Features App

- ✅ Login con username/password
- ✅ PIN a 4 cifre + Biometria (Face ID/Touch ID)
- ✅ Gestione clienti (ricerca, dettagli)
- ✅ Gestione noleggi (lista, dettagli, filtri)
- ✅ Scanner barcode per attrezzature
- ✅ Configurazione server personalizzabile
- ✅ Heartbeat sessione (mantiene utente online)
- ✅ Notifiche push
- ✅ Storage sicuro (Keychain)

---

## 🎯 Checklist Pre-Build

- [ ] Progetto caricato su Git
- [ ] Account Codemagic creato
- [ ] Repository connesso a Codemagic
- [ ] Bundle ID personalizzato
- [ ] Email aggiornata in codemagic.yaml
- [ ] Certificato .p12 caricato su Codemagic
- [ ] Provisioning profile caricato su Codemagic
- [ ] Build avviata
- [ ] IPA scaricato

---

**🎉 Il progetto è pronto! Segui i 3 passi sopra per creare il tuo IPA!**

Per aiuto dettagliato: [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)
