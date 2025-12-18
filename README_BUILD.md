# Build iOS App per Codemagic

## Prerequisiti

Per compilare l'app iOS in un file .ipa hai bisogno di:

1. **Account Apple Developer** (99$/anno) per firmare l'app
2. **Certificati e Provisioning Profile** configurati su Codemagic
3. **Bundle Identifier** unico (es. `com.tuaazienda.mynoleggioapp`)

## Opzione 1: Creare progetto Xcode su Mac (CONSIGLIATO)

Il modo più affidabile è:

1. Apri **Xcode** su un Mac
2. File → New → Project → iOS App
3. Scegli:
   - Product Name: `MyNoleggioApp`
   - Team: il tuo team Apple Developer
   - Organization Identifier: `com.tuaazienda`
   - Interface: SwiftUI
   - Language: Swift
4. Copia tutti i file `.swift` dalla cartella `MyNoleggioApp/` nel progetto Xcode
5. Aggiungi i file al target trascinandoli nel Navigator
6. Copia `Info.plist` e `Assets.xcassets`
7. Build → Archive → Esporta .ipa

## Opzione 2: Usare Codemagic con il progetto esistente

### Configurazione Codemagic

1. Vai su [codemagic.io](https://codemagic.io)
2. Connetti il tuo repository Git
3. Seleziona il progetto
4. Configura:
   - **Code signing**: carica certificati .p12 e provisioning profile
   - **Bundle ID**: `com.mynoleggioapp.app` (o il tuo)
   - **Team ID**: dal tuo account Apple Developer

### File necessari (già creati)

```
IOS/
├── codemagic.yaml          # Configurazione build Codemagic
├── MyNoleggioApp.xcodeproj/
│   ├── project.pbxproj     # Progetto Xcode
│   └── xcshareddata/
│       └── xcschemes/
│           └── MyNoleggioApp.xcscheme
├── MyNoleggioApp/
│   ├── App.swift           # Entry point
│   ├── Info.plist          # Configurazione app
│   ├── Assets.xcassets/    # Icone e colori
│   └── ... (altri file Swift)
```

### Comandi build manuale (su Mac)

```bash
# Build per simulatore
xcodebuild -project MyNoleggioApp.xcodeproj -scheme MyNoleggioApp -sdk iphonesimulator

# Build per device (richiede signing)
xcodebuild -project MyNoleggioApp.xcodeproj -scheme MyNoleggioApp -sdk iphoneos

# Archive per distribuzione
xcodebuild -project MyNoleggioApp.xcodeproj -scheme MyNoleggioApp archive -archivePath build/MyNoleggioApp.xcarchive

# Export IPA
xcodebuild -exportArchive -archivePath build/MyNoleggioApp.xcarchive -exportPath build/ipa -exportOptionsPlist ExportOptions.plist
```

## Opzione 3: Usare Xcode Cloud (integrato in Xcode)

1. Apri il progetto in Xcode
2. Product → Xcode Cloud → Create Workflow
3. Configura build automatici

## Note importanti

### Bundle Identifier
Cambia `com.mynoleggioapp.app` con il tuo identificatore univoco in:
- `codemagic.yaml`
- `project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER)

### Icona App
Aggiungi un'immagine 1024x1024 in:
`MyNoleggioApp/Assets.xcassets/AppIcon.appiconset/`

### Permessi
L'app richiede questi permessi (già configurati in Info.plist):
- Camera (per barcode scanner)
- Face ID (per autenticazione biometrica)

### Deployment Target
L'app richiede iOS 17.0 o superiore.

