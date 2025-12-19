# FIX: App Crasha su AltStore

## Problema
L'app compilata su CodeMagic crasha quando installata su AltStore perché **non è firmata correttamente**.

## Soluzione

### 1. Configura i Certificati su CodeMagic

Vai su CodeMagic → Il tuo progetto → Settings → Code signing

#### Opzione A: Automatic (Più Facile)
1. Clicca su **"Enable automatic code signing"**
2. Collega il tuo Apple ID
3. CodeMagic genererà automaticamente i certificati

#### Opzione B: Manual (Più Controllo)
1. **Genera Certificato Development**:
   ```bash
   # Su Mac, apri Keychain Access
   # Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
   # Salva il file .certSigningRequest
   ```

2. **Su Apple Developer**:
   - Vai su https://developer.apple.com/account/resources/certificates
   - Clicca **+** per nuovo certificato
   - Scegli **iOS App Development**
   - Carica il .certSigningRequest
   - Scarica il certificato (.cer)

3. **Crea Provisioning Profile**:
   - Vai su https://developer.apple.com/account/resources/profiles
   - Clicca **+** per nuovo profile
   - Scegli **iOS App Development**
   - Seleziona App ID: `com.mynoleggioapp.app`
   - Seleziona il certificato appena creato
   - Seleziona i device su cui installare (importante per AltStore!)
   - Scarica il profile (.mobileprovision)

4. **Carica su CodeMagic**:
   - Settings → Code signing identities → iOS
   - Carica certificato (.p12) - password se presente
   - Carica provisioning profile (.mobileprovision)

### 2. Aggiungi Device su Developer Portal

**IMPORTANTE per AltStore**: Il tuo iPhone deve essere registrato!

1. Trova il tuo UDID iPhone:
   - Collega iPhone al Mac
   - Apri Finder → iPhone → Info
   - Clicca su "Model" finché vedi l'UDID (stringa lunga)
   - Copia l'UDID

2. Registra su Apple Developer:
   - https://developer.apple.com/account/resources/devices
   - Clicca **+**
   - Incolla UDID e dai un nome
   - Salva

3. **Aggiorna il Provisioning Profile** con il nuovo device

### 3. Configura Bundle ID e Team

Nel file [codemagic.yaml](codemagic.yaml):
```yaml
vars:
  BUNDLE_ID: "com.tuoaccount.mynoleggioapp"  # CAMBIA!
```

Nel progetto Xcode (project.pbxproj):
- PRODUCT_BUNDLE_IDENTIFIER = com.tuoaccount.mynoleggioapp
- DEVELOPMENT_TEAM = IL_TUO_TEAM_ID (10 caratteri)

### 4. Rebuilda su CodeMagic

Dopo aver configurato tutto:
1. Fai commit e push delle modifiche
2. Triggera un nuovo build su CodeMagic
3. Scarica il nuovo IPA firmato
4. Installa su AltStore

### 5. Alternativa Veloce: Firma Locale

Se hai urgenza, puoi firmare l'IPA localmente:

```bash
# Installa ios-deploy
brew install ios-deploy

# Firma l'IPA non firmato
xcrun codesign --force --sign "Apple Development: TUO_NOME" \
  --entitlements MyNoleggioApp.entitlements \
  Payload/MyNoleggioApp.app

# Ricrea IPA
zip -r MyNoleggioApp-signed.ipa Payload/
```

## Checklist Debug

Se continua a crashare:

- [ ] Device registrato su Developer Portal?
- [ ] Device incluso nel Provisioning Profile?
- [ ] Bundle ID corretto in Xcode e CodeMagic?
- [ ] Certificato Development valido?
- [ ] IPA scaricato dall'ultimo build?
- [ ] AltStore aggiornato all'ultima versione?

## Verifica IPA Firmato

```bash
# Estrai l'IPA
unzip MyNoleggioApp.ipa

# Verifica la firma
codesign -dvv Payload/MyNoleggioApp.app

# Dovresti vedere:
# Authority=Apple Development: TUO_NOME
# Identifier=com.mynoleggioapp.app
# TeamIdentifier=XXXXX
```

Se vedi "code object is not signed at all", l'IPA non è firmato!

## Link Utili

- CodeMagic Docs: https://docs.codemagic.io/yaml-code-signing/signing-ios/
- Apple Developer: https://developer.apple.com/account
- AltStore FAQ: https://altstore.io/faq/

## Note

- **Development** profile funziona con AltStore
- **Ad-hoc** funziona anche, ma serve se hai molti device
- **App Store** NON funziona con AltStore
- Certificato scade dopo 1 anno, rinnovalo prima
