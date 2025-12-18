# 📋 CHECKLIST FINALE - Pronto per Codemagic

Usa questa checklist per verificare che tutto sia pronto prima di caricare su Codemagic.

---

## ✅ FASE 1: Certificati Apple Developer

- [ ] **Account Apple Developer attivo** (€99/anno pagati)
- [ ] **App ID creato** su https://developer.apple.com/account/
  - Bundle ID: `_____________________` (es. com.tuaazienda.mynoleggioapp)
  - Tipo: Explicit (non Wildcard)
- [ ] **Certificato Distribution creato**
  - File `.cer` scaricato e aperto su Mac
  - File `.p12` esportato da Keychain Access
  - Password .p12 salvata: `_____________________`
- [ ] **Provisioning Profile creato**
  - Tipo: Ad-Hoc o App Store
  - File `.mobileprovision` scaricato
  - Collegato al certificato e App ID corretti

---

## ✅ FASE 2: Configurazione Progetto

- [ ] **Bundle ID personalizzato** in:
  - [ ] `codemagic.yaml` (riga 8 e 12)
  - [ ] `MyNoleggioApp.xcodeproj/project.pbxproj`
  - [ ] Verifica corrispondenza con App ID Apple
  
- [ ] **Email notifica configurata** in:
  - [ ] `codemagic.yaml` (riga ~64)
  - Email: `_____________________`

- [ ] **Team ID Apple** (opzionale ma consigliato):
  - Team ID: `_____________________`
  - Dove trovarlo: https://developer.apple.com/account → Membership

- [ ] **Script di controllo eseguito**:
  ```bash
  ./check_project.sh
  ```
  - [ ] Nessun errore critico

---

## ✅ FASE 3: Repository Git

- [ ] **Repository Git creato**
  - Provider: ☐ GitHub  ☐ GitLab  ☐ Bitbucket  ☐ Azure DevOps
  - URL: `_____________________`
  
- [ ] **Codice pushato su Git**:
  ```bash
  git init
  git add .
  git commit -m "Initial commit - iOS project"
  git remote add origin [TUO_URL_REPO]
  git push -u origin main
  ```

- [ ] **File .gitignore configurato** (per evitare di caricare file sensibili)
  - [ ] `.p12` non committato
  - [ ] `.mobileprovision` non committato

---

## ✅ FASE 4: Setup Codemagic

- [ ] **Account Codemagic creato**
  - Link: https://codemagic.io/
  - Piano: ☐ Free (500 min)  ☐ Pro ($49/mese)

- [ ] **Repository connesso a Codemagic**
  - [ ] Codemagic autorizzato ad accedere al repository
  - [ ] Progetto aggiunto su Codemagic
  - [ ] `codemagic.yaml` rilevato automaticamente

- [ ] **Certificati caricati su Codemagic**
  - Path: Settings → Code signing identities → iOS code signing
  - [ ] File `.p12` caricato
  - [ ] Password `.p12` inserita
  - [ ] File `.mobileprovision` caricato
  - [ ] Salvato con successo (messaggio verde)

- [ ] **Workflow configurato**
  - [ ] Workflow `ios-workflow` visibile
  - [ ] Branch selezionato: `main` (o il tuo branch)

---

## ✅ FASE 5: Prima Build

- [ ] **Build avviata manualmente**
  - [ ] Click su "Start new build"
  - [ ] Workflow: `ios-workflow`
  - [ ] Branch: `main`

- [ ] **Build completata con successo**
  - Tempo impiegato: _______ minuti
  - [ ] Nessun errore di code signing
  - [ ] Nessun errore di compilazione Swift

- [ ] **Artifacts scaricati**
  - [ ] File `.ipa` scaricato
  - Dimensione file: _______ MB
  - [ ] File funzionante (testato su device)

---

## ✅ FASE 6: Test e Distribuzione

- [ ] **IPA testato**
  - Metodo di test: ☐ TestFlight  ☐ Installazione diretta  ☐ Diawi
  - [ ] App si apre correttamente
  - [ ] Login funziona
  - [ ] Navigazione OK
  - [ ] Nessun crash immediato

- [ ] **Distribuzione configurata** (opzionale)
  - [ ] TestFlight setup
  - [ ] Tester invitati
  - [ ] App Store Connect configurato

---

## 🎯 RIEPILOGO FINALE

### Informazioni da ricordare:

```
Bundle ID:              _____________________
Team ID:                _____________________
Email notifica:         _____________________
Password .p12:          _____________________
Repository URL:         _____________________
Build Number:           _____________________
```

### Link Utili:

- Apple Developer Portal: https://developer.apple.com/account/
- Codemagic Dashboard: https://codemagic.io/apps
- Repository Git: _____________________

---

## 🚨 In caso di problemi

### Build fallita - Code Signing Error
1. Verifica che Bundle ID corrisponda in tutti i file
2. Ricontrolla certificato e provisioning profile su Codemagic
3. Verifica che certificato non sia scaduto (validità 1 anno)
4. Assicurati che provisioning profile contenga il certificato giusto

### Build fallita - Compilation Error
1. Leggi i log completi in Codemagic
2. Verifica che tutti i file Swift siano presenti
3. Controlla errori di sintassi Swift
4. Esegui check_project.sh per verificare struttura

### IPA non si installa su device
1. (Ad-Hoc) Verifica che UDID device sia nel provisioning profile
2. Verifica che provisioning profile non sia scaduto
3. Prova a rigenerare provisioning profile
4. Usa Apple Configurator 2 per installazione manuale

### Altro
- Consulta: [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md)
- Forum Codemagic: https://github.com/codemagic-ci-cd/codemagic-docs/discussions
- Documentazione: https://docs.codemagic.io/

---

## ✨ Quando tutto è ✅

**Congratulazioni! Hai compilato con successo la tua app iOS!** 🎉

Ora puoi:
- Distribuire l'app via TestFlight
- Invitare beta tester
- Preparare per App Store
- Setup build automatici su push

---

**Data completamento**: _______________
**Note aggiuntive**:
```
_____________________________________
_____________________________________
_____________________________________
```
