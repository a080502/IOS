# Troubleshooting: Crash AltStore

## Problema Originale
App crashava all'installazione su AltStore con errore `File::open` in `ldid::Entitlements`.

## Cause Identificate e Risolte

### 1. ❌ File Swift Mancanti nel Build (CRITICO)
**Problema**: Solo 2 file su 25 venivano compilati  
**Causa**: `project.pbxproj` non referenziava i file  
**Fix**: Script `fix_project.py` ha aggiunto tutti i file mancanti  
**Commit**: `393521d`

### 2. ❌ Entitlements Non Referenziato
**Problema**: File entitlements esisteva ma non era nel progetto Xcode  
**Causa**: Mancava in PBXFileReference e CODE_SIGN_ENTITLEMENTS  
**Fix**: Aggiunto al progetto e configurato nelle Build Settings  
**Commit**: `0ac005b`

### 3. ❌ App Groups negli Entitlements
**Problema**: App Groups richiede provisioning profile valido  
**Causa**: Entitlements troppo complessi per app sideloaded  
**Fix**: Semplificato a solo `get-task-allow`  
**Commit**: `f57e660`

### 4. ❌ Build Completamente Non Firmato (CAUSA PRINCIPALE)
**Problema**: `ldid` (usato da AltStore) non può leggere binari senza code signature  
**Causa**: `CODE_SIGNING_REQUIRED=NO` non crea struttura di firma  
**Fix**: Ad-hoc signing con `codesign --sign -`  
**Commit**: `3e078cd` ⭐ **SOLUZIONE FINALE**

## Come Verificare il Fix

### 1. Controlla il Build Log su CodeMagic
Deve contenere:
```
📦 Firma ad-hoc del binario...
/usr/bin/codesign --force --sign - --entitlements
```

### 2. Verifica l'IPA Scaricato (opzionale)
```bash
# Estrai l'IPA
unzip MyNoleggioApp.ipa

# Verifica che il binario sia firmato
codesign -dvv Payload/MyNoleggioApp.app

# Output atteso:
# Identifier=com.mynoleggioapp.app
# Format=app bundle with Mach-O thin (arm64)
# CodeDirectory v=...
# Signature=adhoc
```

Se vedi `Signature=adhoc`, il fix è corretto! ✅

### 3. Installa su AltStore
- Scarica il **nuovo** IPA da CodeMagic (build dopo commit `3e078cd`)
- Cancella eventuali versioni vecchie dell'app
- Installa tramite AltStore
- L'app dovrebbe installarsi senza crash

## Perché Questo Fix Funziona

### Il Problema di ldid
`ldid` è uno strumento di jailbreak che AltStore usa per manipolare la firma delle app. Funziona così:

1. **Legge** gli entitlements dal binario esistente
2. **Modifica** gli entitlements aggiungendo il tuo Team ID
3. **Ri-firma** l'app con il tuo certificato

Ma `ldid` **richiede** che il binario abbia una struttura di code signature base, anche vuota.

### Build Senza Firma vs Ad-hoc
```
❌ CODE_SIGNING_REQUIRED=NO
   → Binario completamente senza firma
   → Nessuna sezione __LINKEDIT con code signature
   → ldid::File::open() FALLISCE

✅ codesign --sign - (ad-hoc)
   → Crea struttura completa di code signature
   → Sezione __LINKEDIT presente con firma "adhoc"
   → ldid può leggere e modificare
   → AltStore ri-firma con successo
```

## Build Alternatives (se il problema persiste)

### Opzione A: Firma con Free Developer Certificate
Se hai un Mac:
```bash
# Crea certificato free (non richiede account pagante)
# Apri Xcode → Settings → Accounts → Aggiungi Apple ID

# Builda localmente
xcodebuild archive -project MyNoleggioApp.xcodeproj -scheme MyNoleggioApp
xcodebuild -exportArchive -archivePath ... -exportOptionsPlist ...

# L'IPA sarà già firmato correttamente
```

### Opzione B: Sideloadly o AltStore con IPA Locale
Se preferisci non usare CodeMagic:
1. Build locale su Mac con Xcode
2. Export IPA con Development provisioning
3. Usa Sideloadly o AltStore per installare

## Note Tecniche

### Perché il Primo Approccio Falliva
I primi tentativi usavano:
- Build senza code signing → ldid non funziona
- Provisioning profiles complessi → non necessari per sideload

### Perché Ad-hoc Signing Funziona
- Crea la struttura minima necessaria
- Compatibile con qualsiasi device (non richiede UDID registrato)
- AltStore può ri-firmare sopra

### Entitlements Minimi
Per sideload serve solo:
```xml
<key>get-task-allow</key>
<true/>
```

Capabilities avanzate (App Groups, HealthKit, etc.) richiedono provisioning profile vero.

## Timeline Fix

| Commit | Problema | Stato |
|--------|----------|-------|
| 6ac1eb5 | Crash app all'avvio | ⚠️ Parziale |
| 393521d | File Swift mancanti | ⚠️ Parziale |
| 0ac005b | Entitlements mancante | ⚠️ Parziale |
| f57e660 | App Groups complessi | ⚠️ Parziale |
| **3e078cd** | **Build non firmato** | ✅ **RISOLTO** |

## Supporto

Se dopo aver installato l'IPA del build `3e078cd` o successivo il problema persiste:

1. Verifica la firma dell'IPA (vedi sopra)
2. Controlla il build log su CodeMagic
3. Invia i crash log più recenti

Il fix è definitivo se l'IPA ha la firma ad-hoc corretta.
