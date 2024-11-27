import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revolutionary_stuff/screens/generate_home_screen.dart';
import 'package:revolutionary_stuff/screens/history_screen.dart';
import 'package:revolutionary_stuff/screens/onboarding.dart';
import 'package:revolutionary_stuff/screens/scan_home_screen.dart';
import 'package:revolutionary_stuff/screens/splash_screen.dart';

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    routeMethod(name: '', screen: SplashScreen()),
    routeMethod(name: 'onboarding', screen: OnboardingScreen()),
    routeMethod(name: 'home', screen: ScanHomeScreen()),
    routeMethod(name: 'generateHome', screen: GenerateHomeScreen()),
    routeMethod(name: 'history', screen: HistoryScreen()),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final loggedIn =
        state.uri.toString() != '/auth' && state.uri.toString() != '/sign-up';
    final loggingIn =
        state.uri.toString() == '/auth' || state.uri.toString() == '/sign-up';
    if (!loggedIn && !loggingIn) return '/auth';
    return null;
  },
);

GoRoute routeMethod({required String name, required Widget screen}) {
  return GoRoute(
    name: name == '' ? 'splash' : name,
    path: '/$name',
    builder: (BuildContext context, GoRouterState state) => screen,
  );
}

GoRouter get router => _router;
