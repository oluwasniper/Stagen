import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../l10n/l10n.dart';

/// Keys used for persisting settings.
class _Keys {
  static const vibrate = 'setting_vibrate';
  static const beep = 'setting_beep';
  static const locale = 'setting_locale';
  static const analytics = 'setting_analytics';
}

/// Holds the app settings state.
class SettingsState {
  final bool vibrate;
  final bool beep;
  final bool analyticsEnabled;

  const SettingsState({
    this.vibrate = false,
    this.beep = false,
    this.analyticsEnabled = true,
  });

  SettingsState copyWith({bool? vibrate, bool? beep, bool? analyticsEnabled}) {
    return SettingsState(
      vibrate: vibrate ?? this.vibrate,
      beep: beep ?? this.beep,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}

/// Manages persisted app settings via secure storage.
class SettingsNotifier extends StateNotifier<SettingsState> {
  final FlutterSecureStorage _storage;

  SettingsNotifier(this._storage) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final vibrate = await _storage.read(key: _Keys.vibrate);
    final beep = await _storage.read(key: _Keys.beep);
    final analytics = await _storage.read(key: _Keys.analytics);
    // Default true (opt-in); only explicitly stored 'false' disables it.
    final analyticsEnabled = analytics != 'false';
    state = SettingsState(
      vibrate: vibrate == 'true',
      beep: beep == 'true',
      analyticsEnabled: analyticsEnabled,
    );
    // Apply persisted consent state to the PostHog SDK on startup so the
    // PosthogObserver respects the user's previous choice immediately.
    if (analyticsEnabled) {
      await Posthog().enable();
    } else {
      await Posthog().disable();
    }
  }

  Future<void> toggleVibrate(bool value) async {
    state = state.copyWith(vibrate: value);
    await _storage.write(key: _Keys.vibrate, value: value.toString());
  }

  Future<void> toggleBeep(bool value) async {
    state = state.copyWith(beep: value);
    await _storage.write(key: _Keys.beep, value: value.toString());
  }

  Future<void> toggleAnalytics(bool value) async {
    state = state.copyWith(analyticsEnabled: value);
    await _storage.write(key: _Keys.analytics, value: value.toString());
    if (value) {
      await Posthog().enable();
    } else {
      await Posthog().disable();
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(const FlutterSecureStorage());
});

// ── Locale provider ────────────────────────────────────────────────────────

/// Notifier that persists the user's chosen [Locale].
class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage;

  LocaleNotifier(this._storage) : super(L10n.all.first) {
    _load();
  }

  Future<void> _load() async {
    final code = await _storage.read(key: _Keys.locale);
    if (code != null) {
      final match = L10n.all.where(
        (l) => l.languageCode == code,
      );
      if (match.isNotEmpty) {
        state = match.first;
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.write(key: _Keys.locale, value: locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(const FlutterSecureStorage());
});
