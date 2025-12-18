# 🔐 Variabili Ambiente Codemagic (Opzionali)

Questo file contiene le variabili d'ambiente che puoi configurare su Codemagic per funzionalità avanzate.

## 📍 Dove configurarle

1. Dashboard Codemagic → Tuo progetto
2. **Settings** → **Environment variables**
3. Click **Add variable**

---

## 🔑 Variabili Base (Obbligatorie)

Queste sono già configurate in `codemagic.yaml`, ma puoi sovrascriverle:

| Nome | Valore | Descrizione |
|------|--------|-------------|
| `BUNDLE_ID` | `com.tuaazienda.mynoleggioapp` | Bundle identifier app |
| `XCODE_PROJECT` | `MyNoleggioApp.xcodeproj` | Nome progetto Xcode |
| `XCODE_SCHEME` | `MyNoleggioApp` | Scheme Xcode da buildare |

---

## 📦 TestFlight & App Store Connect (Opzionali)

Per pubblicare automaticamente su TestFlight dopo ogni build:

### 1. Crea API Key su App Store Connect

1. Vai su https://appstoreconnect.apple.com/
2. **Users and Access** → **Keys** (tab)
3. Click **+ (Generate API Key)**
4. Nome: `Codemagic CI/CD`
5. Access: **App Manager** o **Developer**
6. **Generate** → Scarica file `.p8`

### 2. Configura su Codemagic

| Nome Variabile | Valore | Dove trovarlo |
|----------------|--------|---------------|
| `APP_STORE_CONNECT_ISSUER_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | App Store Connect → Keys → Issuer ID |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | `XXXXXXXXXX` | App Store Connect → Keys → Key ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Contenuto file `.p8` | File scaricato |

**Tipo**: Group → `secure` (per nascondere i valori)

### 3. Attiva in codemagic.yaml

Decommentare queste righe in `codemagic.yaml`:

```yaml
publishing:
  app_store_connect:
    api_key: $APP_STORE_CONNECT_PRIVATE_KEY
    key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
    issuer_id: $APP_STORE_CONNECT_ISSUER_ID
    submit_to_testflight: true
```

---

## 💬 Notifiche Slack (Opzionali)

Per ricevere notifiche delle build su Slack:

### 1. Crea Webhook Slack

1. Vai su https://api.slack.com/apps
2. **Create New App** → **From scratch**
3. Nome: `Codemagic Builds`
4. Workspace: [Tuo workspace]
5. **Incoming Webhooks** → **Activate**
6. **Add New Webhook to Workspace**
7. Seleziona canale (es. `#builds`)
8. Copia **Webhook URL**

### 2. Configura su Codemagic

| Nome Variabile | Valore | Esempio |
|----------------|--------|---------|
| `SLACK_WEBHOOK_URL` | `https://hooks.slack.com/services/...` | Copiato da Slack |

### 3. Attiva in codemagic.yaml

Decommentare queste righe in `codemagic.yaml`:

```yaml
publishing:
  slack:
    channel: '#builds'
    notify_on_build_start: false
    notify:
      success: true
      failure: true
```

E aggiungi in `environment.vars`:
```yaml
SLACK_WEBHOOK_URL: $SLACK_WEBHOOK_URL
```

---

## 🔔 Notifiche Email (Già Configurate)

Le notifiche email sono già attive. Per modificarle:

```yaml
publishing:
  email:
    recipients:
      - email1@example.com
      - email2@example.com
    notify:
      success: true    # Notifica su build riuscita
      failure: true    # Notifica su build fallita
```

---

## 📊 Variabili Avanzate

### Build Number Automatico

Per incrementare automaticamente il build number:

```yaml
scripts:
  - name: Increment build number
    script: |
      BUILD_NUMBER=$(($(date +%Y%m%d%H%M)))
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" MyNoleggioApp/Info.plist
```

### Version basata su Git Tag

```yaml
scripts:
  - name: Set version from git tag
    script: |
      VERSION=$(git describe --tags --abbrev=0)
      /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" MyNoleggioApp/Info.plist
```

### Custom Server URL (per test)

| Nome Variabile | Valore | Uso |
|----------------|--------|-----|
| `API_BASE_URL` | `https://test.tuodominio.it` | URL server test |
| `API_BASE_URL_PROD` | `https://api.tuodominio.it` | URL server prod |

Usale nel codice Swift:
```swift
let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "default"
```

---

## 🎯 Template Configurazione Completa

File: `codemagic.yaml` con tutto attivo:

```yaml
workflows:
  ios-workflow:
    environment:
      vars:
        XCODE_PROJECT: "MyNoleggioApp.xcodeproj"
        XCODE_SCHEME: "MyNoleggioApp"
        BUNDLE_ID: "com.tuaazienda.mynoleggioapp"
        APP_STORE_CONNECT_ISSUER_ID: $APP_STORE_CONNECT_ISSUER_ID
        APP_STORE_CONNECT_KEY_IDENTIFIER: $APP_STORE_CONNECT_KEY_IDENTIFIER
        APP_STORE_CONNECT_PRIVATE_KEY: $APP_STORE_CONNECT_PRIVATE_KEY
        SLACK_WEBHOOK_URL: $SLACK_WEBHOOK_URL
```

---

## 🔒 Sicurezza

**⚠️ MAI committare su Git:**
- ❌ File `.p12`
- ❌ File `.mobileprovision`
- ❌ API Keys
- ❌ Webhook URLs
- ❌ Password

**✅ Usa sempre le variabili d'ambiente di Codemagic**

---

## 📚 Riferimenti

- **Codemagic Environment Variables**: https://docs.codemagic.io/yaml-basic-configuration/configuring-environment-variables/
- **App Store Connect API**: https://developer.apple.com/documentation/appstoreconnectapi
- **Slack Incoming Webhooks**: https://api.slack.com/messaging/webhooks

---

**Note**: Tutte queste configurazioni sono **opzionali**. Il progetto funziona già senza di esse!
