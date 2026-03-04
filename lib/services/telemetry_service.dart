import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../config/app_config.dart';
import '../providers/settings_provider.dart';

// ─── Event Name Constants ─────────────────────────────────────────────────────
//
// All event names are defined here as constants — a single catalog that is easy
// to audit. Every call site uses these constants rather than raw strings.

abstract final class TelemetryEvents {
  // Auth
  static const String authSignupEmail = 'auth_signup_email';
  static const String authSigninEmail = 'auth_signin_email';
  static const String authSigninAnonymous = 'auth_signin_anonymous';
  static const String authAccountLinked = 'auth_account_linked';
  static const String authSignout = 'auth_signout';
  static const String authError = 'auth_error';
  static const String sessionResumed = 'session_resumed';

  // QR Generation
  static const String qrTypeSelected = 'qr_type_selected';
  static const String qrGenerated = 'qr_generated';
  static const String contactImportRequested = 'contact_import_requested';
  static const String contactImportSuccess = 'contact_import_success';
  static const String contactImportDenied = 'contact_import_denied';

  // QR Scanning
  static const String qrScanned = 'qr_scanned';
  static const String scannerTorchToggled = 'scanner_torch_toggled';
  static const String scannerCameraSwitched = 'scanner_camera_switched';

  // QR Actions
  static const String qrCopied = 'qr_copied';
  static const String qrUrlOpened = 'qr_url_opened';
  static const String qrShared = 'qr_shared';

  // History
  static const String historyItemDeleted = 'history_item_deleted';
  static const String historyItemViewed = 'history_item_viewed';
  static const String historyRefreshed = 'history_refreshed';

  // Settings
  static const String settingVibrationToggled = 'setting_vibration_toggled';
  static const String settingBeepToggled = 'setting_beep_toggled';
  static const String languageChanged = 'language_changed';
  static const String telemetryOptedOut = 'telemetry_opted_out';
  static const String telemetryOptedIn = 'telemetry_opted_in';
}

// ─── TelemetryService ─────────────────────────────────────────────────────────

class TelemetryService {
  final bool _analyticsEnabled;

  const TelemetryService({required bool analyticsEnabled})
      : _analyticsEnabled = analyticsEnabled;

  bool get isEnabled => _analyticsEnabled;

  /// Track an event with optional properties.
  ///
  /// This method never throws. Any PostHog error is caught and logged via
  /// dart:developer so the app never crashes due to telemetry.
  void track(String event, {Map<String, Object>? properties}) {
    if (!_analyticsEnabled) return;
    Posthog()
        .capture(eventName: event, properties: properties)
        .catchError((Object e, StackTrace st) {
      dev.log(
        '[TelemetryService] track failed for "$event": $e',
        stackTrace: st,
        name: 'TelemetryService',
      );
    });
  }

  /// Identify the current user. Call after successful authentication.
  ///
  /// [userId] is the Appwrite user.\$id (an opaque UUID — not PII).
  /// Never pass email addresses or names here.
  void identify(String userId) {
    if (!_analyticsEnabled) return;
    Posthog().identify(userId: userId).catchError((Object e, StackTrace st) {
      dev.log(
        '[TelemetryService] identify failed: $e',
        stackTrace: st,
        name: 'TelemetryService',
      );
    });
  }

  /// Reset PostHog identity on sign-out. Clears the distinct ID.
  void reset() {
    if (!_analyticsEnabled) return;
    Posthog().reset().catchError((Object e, StackTrace st) {
      dev.log(
        '[TelemetryService] reset failed: $e',
        stackTrace: st,
        name: 'TelemetryService',
      );
    });
  }
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────

/// Provides a [TelemetryService] whose enabled state tracks [settingsProvider].
///
/// Automatically rebuilds when the user toggles analytics in Settings.
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  final settings = ref.watch(settingsProvider);
  return TelemetryService(analyticsEnabled: settings.analyticsEnabled);
});

// ─── PostHog Initialization ───────────────────────────────────────────────────

/// Call once in main() before runApp().
///
/// Uses [AppConfig] values injected at build time via --dart-define.
/// If the API key is empty (defines not passed), PostHog silently no-ops
/// rather than crashing.
///
/// Reads the persisted analytics preference from [FlutterSecureStorage] and
/// calls [Posthog().disable()] immediately after setup when the user has
/// previously opted out, so no events are captured before [ProviderScope]
/// or [SettingsNotifier] are initialised.
Future<void> initPostHog() async {
  if (AppConfig.posthogApiKey.isEmpty) return;

  final config = PostHogConfig(AppConfig.posthogApiKey)
    ..host = AppConfig.posthogHost
    ..debug = false
    ..captureApplicationLifecycleEvents = false;

  await Posthog().setup(config);

  // Respect persisted opt-out before any capture can occur.
  try {
    const storage = FlutterSecureStorage();
    final analyticsValue = await storage.read(key: kSettingAnalyticsKey);
    // Mirror SettingsNotifier: only 'true' enables analytics; null (first-run)
    // and any other value are treated as disabled.
    if (analyticsValue != 'true') {
      try {
        await Posthog().disable();
      } catch (disableError, disableSt) {
        dev.log(
          '[TelemetryService] failed to disable PostHog after read failure: $disableError',
          stackTrace: disableSt,
          name: 'TelemetryService',
        );
      }
    }
  } catch (e, st) {
    dev.log(
      '[TelemetryService] failed to read analytics preference: $e',
      stackTrace: st,
      name: 'TelemetryService',
    );
    try {
      await Posthog().disable();
    } catch (disableError, disableStack) {
      dev.log(
        '[TelemetryService] failed to disable PostHog after preference read failure: $disableError',
        stackTrace: disableStack,
        name: 'TelemetryService',
      );
    }
  }
}
