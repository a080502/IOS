# 🚀 Guida Completa: Build iOS con Codemagic

## 📋 Prerequisiti

### 1. Account Apple Developer
- **Costo**: €99/anno
- **Link**: https://developer.apple.com/programs/
- **Necessario per**: firmare l'app e distribuirla

### 2. Account Codemagic
- **Gratuito** per progetti personali (500 minuti build/mese)
- **Link**: https://codemagic.io/
- **Pro**: $49/mese (build illimitati)

### 3. Repository Git
- GitHub, GitLab, Bitbucket o Azure DevOps
- Il codice deve essere in un repository

---

## 🔧 Step 1: Preparazione Certificati Apple

### A. Crea App ID su Apple Developer Portal

1. Vai su https://developer.apple.com/account/
2. Vai in **Certificates, Identifiers & Profiles**
3. Clicca **Identifiers** → **+ (Add)**
4. Scegli **App IDs** → **Continue**
5. Configura:
   - **Description**: MyNoleggio App
   - **Bundle ID**: `com.tuaazienda.mynoleggioapp` (ESPLICITO)
   - **Capabilities**: Camera, Push Notifications (se necessario)
6. **Register**

### B. Crea Certificato di Distribuzione

1. Nel portale Apple, vai su **Certificates** → **+ (Add)**
2. Scegli **iOS Distribution** (per App Store/Ad-Hoc)
3. Clicca **Continue**
4. Genera CSR (Certificate Signing Request):
   - Su Mac: apri **Keychain Access**
   - Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate From a Certificate Authority**
   - Email: la tua email
   - Nome: il tuo nome
   - **Saved to disk**
5. Carica il file CSR generato
6. Scarica il certificato `.cer` e aprilo (si aggiunge al Keychain)

### C. Esporta Certificato come .p12

1. Apri **Keychain Access** su Mac
2. Trova il certificato "Apple Distribution: ..."
3. Tasto destro → **Export "Apple Distribution: ..."**
4. Salva come `.p12`
5. Imposta una password (ricordala!)

### D. Crea Provisioning Profile

1. Nel portale Apple, vai su **Profiles** → **+ (Add)**
2. Scegli **Ad Hoc** (per distribuzione interna) o **App Store** (per TestFlight/Store)
3. Seleziona l'**App ID** creato prima
4. Seleziona il **Certificato** creato prima
5. Seleziona i **Dispositivi** (solo per Ad-Hoc)
6. Dai un nome: `MyNoleggio AdHoc Profile`
7. Scarica il file `.mobileprovision`

---

## 🌐 Step 2: Setup Codemagic

### A. Connetti Repository

1. Vai su https://codemagic.io/ e fai login
2. Clicca **Add application**
3. Connetti il tuo provider Git (GitHub/GitLab/Bitbucket)
4. Autorizza Codemagic ad accedere ai tuoi repository
5. Seleziona il repository con il progetto iOS
6. Codemagic rileverà automaticamente `codemagic.yaml`

### B. Carica Certificati di Code Signing

1. Nel progetto Codemagic, vai su **Settings** → **Code signing identities**
2. Sezione **iOS code signing**:

   **Certificato:**
   - Clicca **Choose file**
   - Carica il file `.p12` esportato
   - Inserisci la password del .p12
   
   **Provisioning Profile:**
   - Clicca **Choose file**
   - Carica il file `.mobileprovision`

3. Clicca **Save**

### C. Configura Variabili d'Ambiente

1. Nel progetto, vai su **Settings** → **Environment variables**
2. Aggiungi (se necessario):
   - `APP_STORE_CONNECT_ISSUER_ID`: per TestFlight
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`: per TestFlight
   - `APP_STORE_CONNECT_PRIVATE_KEY`: per TestFlight

---

## 📝 Step 3: Personalizza la Configurazione

### A. Aggiorna Bundle Identifier

Modifica questi file per usare il TUO bundle ID:

**1. codemagic.yaml** (righe 8 e 12):
```yaml
bundle_identifier: com.tuaazienda.mynoleggioapp
```

**2. Info.plist** (già configurato con variabile dinamica):
```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

**3. project.pbxproj** - Cerca `PRODUCT_BUNDLE_IDENTIFIER` e cambia con il tuo

### B. Aggiorna Email di Notifica

In `codemagic.yaml` (riga 64):
```yaml
recipients:
  - tua.email@example.com
```

### C. Scegli il Tipo di Distribuzione

In `codemagic.yaml` (riga 7):
```yaml
distribution_type: ad-hoc  # Opzioni: development, ad-hoc, app-store
```

- **development**: per test su dispositivi registrati durante lo sviluppo
- **ad-hoc**: per distribuzione beta a un gruppo limitato di tester
- **app-store**: per pubblicazione su TestFlight/App Store

---

## 🚀 Step 4: Avvia la Build

### Opzione A: Build Manuale

1. In Codemagic, vai alla dashboard del progetto
2. Clicca **Start new build**
3. Seleziona:
   - **Branch**: main (o il tuo branch)
   - **Workflow**: ios-workflow
4. Clicca **Start new build**

### Opzione B: Build Automatica

Il file `codemagic.yaml` configura build automatiche:
- Ad ogni **push** su branch configurati
- Ad ogni **pull request**

Per configurare trigger:
```yaml
triggering:
  events:
    - push
    - pull_request
  branch_patterns:
    - pattern: 'main'
    - pattern: 'develop'
```

---

## 📦 Step 5: Scarica l'IPA

1. Aspetta che la build finisca (5-15 minuti)
2. Se successo ✅, vai su **Artifacts**
3. Scarica il file `.ipa`

**L'IPA è pronto per essere installato!**

---

## 📲 Come Installare l'IPA

### Opzione 1: TestFlight (CONSIGLIATO)
1. Carica l'IPA su App Store Connect
2. Invita tester tramite email
3. I tester scaricano l'app TestFlight e installano

### Opzione 2: Installazione Diretta (Ad-Hoc)
1. Usa **Apple Configurator 2** (Mac)
2. Usa servizi come **Diawi.com** o **InstallOnAir**
3. Collega iPhone via cavo e usa Xcode → Window → Devices

### Opzione 3: Enterprise Distribution
Richiede account Apple Developer Enterprise ($299/anno)

---

## 🔍 Troubleshooting

### ❌ Errore: "Code signing error"
**Causa**: Certificato o provisioning profile non validi
**Soluzione**:
- Verifica che il bundle ID corrisponda in tutti i file
- Ricarica certificato e provisioning profile su Codemagic
- Verifica che il certificato non sia scaduto

### ❌ Errore: "No such scheme"
**Causa**: Nome scheme errato in codemagic.yaml
**Soluzione**: Verifica con:
```bash
xcodebuild -list -project MyNoleggioApp.xcodeproj
```

### ❌ Errore: "Build failed"
**Causa**: Errori di compilazione Swift
**Soluzione**: Leggi i log dettagliati in Codemagic e correggi gli errori Swift

### ❌ Errore: "Device not registered"
**Causa**: (Solo Ad-Hoc) UDID device non nel provisioning profile
**Soluzione**: Aggiungi device UDID al portale Apple e rigenera provisioning profile

---

## 📊 Costi Stimati

| Servizio | Piano | Costo |
|----------|-------|-------|
| Apple Developer | Standard | €99/anno |
| Codemagic | Free | Gratis (500 min/mese) |
| Codemagic | Pro | $49/mese |
| Apple Developer Enterprise | Enterprise | $299/anno |

---

## 🎯 Checklist Finale

- [ ] Account Apple Developer attivo
- [ ] Bundle ID creato su Apple Developer Portal
- [ ] Certificato Distribution esportato come .p12
- [ ] Provisioning Profile scaricato
- [ ] Progetto su repository Git
- [ ] Codemagic connesso al repository
- [ ] Certificati caricati su Codemagic
- [ ] Bundle ID aggiornato in tutti i file
- [ ] Email di notifica configurata
- [ ] Build avviata su Codemagic
- [ ] IPA scaricato e testato

---

## 📚 Link Utili

- **Codemagic Docs**: https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/
- **Apple Developer**: https://developer.apple.com/
- **Code Signing Guide**: https://docs.codemagic.io/code-signing-yaml/signing-ios/
- **TestFlight**: https://developer.apple.com/testflight/

---

## 🆘 Supporto

Problemi? Controlla:
1. **Log build** su Codemagic
2. **Documentazione** Codemagic (link sopra)
3. **Forum** Codemagic: https://github.com/codemagic-ci-cd/codemagic-docs/discussions
4. **Support** Codemagic (piani a pagamento)

---

**✨ Buona build!**
