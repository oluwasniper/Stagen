# revolutionary_stuff

A new Flutter project for qr-code scanning and generation

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## iOS Wi-Fi SSID Setup (Real Device)

To make the Wi-Fi picker/connected-SSID fallback work reliably on iPhone,
complete these steps in Xcode for `ios/Runner.xcworkspace`:

1. Open `Runner` target → **Signing & Capabilities**.
2. Add capability: **Access WiFi Information**.
3. Ensure location permission text exists in `ios/Runner/Info.plist`:
	- `NSLocationWhenInUseUsageDescription`
4. On device, allow **Location While Using App** and keep Location Services on.

Notes:
- iOS may return no nearby scan results depending on OS/device restrictions.
- In that case, the app falls back to the current connected SSID when available.

## Troubleshooting (iOS Wi-Fi SSID)

- **No network appears in picker**
	- Confirm app has Location permission (**While Using App**).
	- Confirm Location Services are enabled on the device.
	- Confirm **Access WiFi Information** capability is enabled in Xcode.

- **Only connected network is shown**
	- Expected on some iOS versions/devices.
	- The app uses connected-SSID fallback when full scan results are unavailable.

- **SSID shows as unknown / empty**
	- Toggle Wi-Fi off/on and reconnect to a known network.
	- Re-check Location permission after reconnecting.

- **Works in debug but not release/TestFlight**
	- Verify the same capabilities and entitlements are present in the release signing profile.

- **Simulator behavior differs from real device**
	- Test SSID features on a physical iPhone; simulator network APIs can be limited.
# Revolutionary-stuff
