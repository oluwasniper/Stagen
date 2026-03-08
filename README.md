# Scagen

A free, open-source Flutter app for QR code scanning and generation.

> Contributions, bug reports, and feature requests are welcome!

---

## Features

- Scan QR codes using your camera or from a gallery image
- Generate QR codes for text, URLs, Wi-Fi, contacts, events, locations, email, phone, WhatsApp, Instagram, and more
- Offline-first history — syncs to the cloud when online
- Multi-language support (English, Spanish, French, Portuguese)
- Anonymous usage analytics via PostHog (opt-out available in settings)
- Code push updates via Shorebird

---

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (≥ 3.3.3)
- An [Appwrite](https://appwrite.io) project (cloud or self-hosted)
- Optional: a [PostHog](https://posthog.com) project for analytics

### 1. Clone & install dependencies

```bash
git clone https://github.com/oluwasniper/Stagen.git
cd scagen
flutter pub get
```

### 2. Configure environment

```bash
cp .env.example .env
```

Fill in `.env` with your own values:

| Variable | Description |
|---|---|
| `APPWRITE_ENDPOINT` | Your Appwrite API URL (e.g. `https://fra.cloud.appwrite.io/v1`) |
| `APPWRITE_PROJECT_ID` | Found in Appwrite Console → Project Settings |
| `APPWRITE_PROJECT_NAME` | Display name (optional) |
| `POSTHOG_API_KEY` | PostHog project API key — leave empty to disable analytics |
| `POSTHOG_HOST` | PostHog host (`https://us.i.posthog.com` by default) |

> `.env` is gitignored and never committed. See `.env.example` for a template.

### 3. Run

```bash
make run
# or
flutter run --dart-define-from-file=.env
```

### 4. Build

```bash
make build-android   # APK (release)
make build-ios       # iOS (release)
```

---

## Appwrite Setup

This app requires an Appwrite project with a database and collection. You will need to create:

- **Database ID:** `scagen_db`
- **Collection ID:** `qr_records`
- **Collection attributes:**

| Attribute | Type | Required |
|---|---|---|
| `data` | String | Yes |
| `type` | String (`scanned` / `generated`) | Yes |
| `qrType` | String | Yes |
| `label` | String | No |
| `userId` | String | No |
| `createdAt` | String (ISO 8601) | Yes |

Set collection permissions to allow read/write for authenticated users (including anonymous sessions).

---

## VS Code Setup

```bash
cp .vscode/launch.json.example .vscode/launch.json
```

This pre-configures debug, profile, and release launch targets with `--dart-define-from-file=.env` so you can use the VS Code Run panel directly.

---

## Contributing

1. Fork the repo and create a branch from `main`
2. Make your changes
3. Open a pull request with a clear description of what you changed and why

Please keep PRs focused — one feature or fix per PR.

### Reporting bugs

Open an issue and include:
- Device / OS version
- Steps to reproduce
- What you expected vs. what happened

---

## iOS Wi-Fi SSID Setup (Real Device)

To make the Wi-Fi picker/connected-SSID fallback work reliably on iPhone, complete these steps in Xcode for `ios/Runner.xcworkspace`:

1. Open `Runner` target → **Signing & Capabilities**.
2. Add capability: **Access WiFi Information**.
3. Ensure location permission text exists in `ios/Runner/Info.plist`:
   - `NSLocationWhenInUseUsageDescription`
4. On device, allow **Location While Using App** and keep Location Services on.

**Troubleshooting:**
- **No network appears in picker** — Confirm location permission and **Access WiFi Information** capability.
- **Only connected network shown** — Expected on some iOS versions; the app falls back to the connected SSID.
- **SSID shows as unknown** — Toggle Wi-Fi off/on and reconnect.
- **Works in debug but not release/TestFlight** — Verify capabilities are present in the release signing profile.
- **Simulator differs from real device** — Test SSID features on a physical iPhone.

---

## Process Highlighted Text → Scagen

### Android

- Highlight text in another app → tap **Process text** → choose **Scagen**
- Scagen opens the Generate flow, auto-detects the best QR type, and prefills the form.

### iOS

Scagen accepts text via custom URL scheme:

```
scagen://process-text?text=<urlencoded text>
```

Use an iOS Shortcut or share extension to forward selected text into Scagen.

---

## License

[MIT](LICENSE) © oluwasniper and sonofnos
