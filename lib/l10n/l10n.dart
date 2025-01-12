import 'package:flutter/material.dart';

/// This class is used to define the supported locales for the app
/// It is used in the main.dart file
/// e.g. supportedLocales: L10n.all,
/// It is also used in the AppLocalizations.dart file
/// e.g. static const all = [const Locale('en', 'US'), const Locale('pt', 'BR')];
class L10n {
  static final all = [
    const Locale('en', 'US'), //Default, US English
    const Locale('pt', 'BR'), // Brazilian Portugese
    const Locale('fr', 'FR'), // French
    const Locale('es', 'ES'), // Spanish
  ];
}
