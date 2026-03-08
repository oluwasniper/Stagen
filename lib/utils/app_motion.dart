import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized motion configuration and reduced-motion handling.
class AppMotion {
  final bool reduceMotion;

  const AppMotion._({required this.reduceMotion});

  bool get enabled => !reduceMotion;

  static const Duration ultraFast = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 340);
  static const Duration slow = Duration(milliseconds: 520);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;

  static AppMotion of(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);
    return AppMotion._(reduceMotion: reduceMotion);
  }

  Duration duration(Duration normal, {Duration reduced = Duration.zero}) {
    return reduceMotion ? reduced : normal;
  }

  Duration delay(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }

  Curve curve(Curve normal, {Curve reduced = Curves.linear}) {
    return reduceMotion ? reduced : normal;
  }
}

/// Runtime feedback preferences synced from Settings.
abstract final class AppFeedbackPreferences {
  static bool vibrateEnabled = true;
  static bool beepEnabled = true;

  static void configure({
    required bool vibrate,
    required bool beep,
  }) {
    vibrateEnabled = vibrate;
    beepEnabled = beep;
  }
}

/// Motion-aware haptic utilities so tactile feedback follows accessibility mode.
abstract final class AppHaptics {
  static Future<void> selection(BuildContext context) async {
    if (!AppFeedbackPreferences.vibrateEnabled) return;
    if (AppMotion.of(context).reduceMotion) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> light(BuildContext context) async {
    if (!AppFeedbackPreferences.vibrateEnabled) return;
    if (AppMotion.of(context).reduceMotion) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium(BuildContext context) async {
    if (!AppFeedbackPreferences.vibrateEnabled) return;
    if (AppMotion.of(context).reduceMotion) return;
    await HapticFeedback.mediumImpact();
  }
}

/// Motion-aware audio feedback utilities.
abstract final class AppSounds {
  static Future<void> click() async {
    if (!AppFeedbackPreferences.beepEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }
}
