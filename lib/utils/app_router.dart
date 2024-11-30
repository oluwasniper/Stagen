import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revolutionary_stuff/bottom_nav.dart';
import 'package:revolutionary_stuff/screens/generate_home_screen.dart';
import 'package:revolutionary_stuff/screens/generated_qr_screen.dart';
import 'package:revolutionary_stuff/screens/history_screen.dart';
import 'package:revolutionary_stuff/screens/onboarding.dart';
import 'package:revolutionary_stuff/screens/scan_home_screen.dart';
import 'package:revolutionary_stuff/screens/scanned_qr_screen.dart';
import 'package:revolutionary_stuff/screens/settings_screen.dart';
import 'package:revolutionary_stuff/screens/splash_screen.dart';
import 'package:revolutionary_stuff/utils/route/app_name.dart';
import 'package:revolutionary_stuff/utils/route/app_path.dart';
import 'package:revolutionary_stuff/utils/route/error_screen.dart';

class AppGoRouter {
  static GoRouter get router => _router;

  static final GlobalKey<NavigatorState> mainNavigatorKey =
      GlobalKey<NavigatorState>(
    debugLabel: 'mainNavigatorKey',
  );

  static final GlobalKey<NavigatorState> scanHomeTabNavigatorKey =
      GlobalKey<NavigatorState>(
    debugLabel: 'scanHomeTabNavigatorKey',
  );

  static final GlobalKey<NavigatorState> generateHomeTabNavigatorKey =
      GlobalKey<NavigatorState>(
    debugLabel: 'generateHomeTabNavigatorKey',
  );

  static final GlobalKey<NavigatorState> historyTabNavigatorKey =
      GlobalKey<NavigatorState>(
    debugLabel: 'historyTabNavigatorKey',
  );

  static final GlobalKey<NavigatorState> scannedQRNavigatorKey =
      GlobalKey<NavigatorState>(
    debugLabel: 'scannedQRNavigatorKey',
  );

  static final GlobalKey<NavigatorState> generatedQRNavigatorKey =
      GlobalKey<NavigatorState>(
    debugLabel: 'generatedQRNavigatorKey',
  );

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static final GoRouter _router = GoRouter(
    /// debugLogDiagnostics: true, will print the diagnostics in the console
    debugLogDiagnostics: true,

    navigatorKey: mainNavigatorKey,
    initialLocation: AppPath.splash,
    errorBuilder: (context, state) => ErrorScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: mainNavigatorKey,
        builder: (context, state, navigationShell) {
          return BottomNavigationPage(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: generateHomeTabNavigatorKey,
            routes: [
              GoRoute(
                path: AppPath.generateHome,
                name: PathName.generateHome,
                parentNavigatorKey: generateHomeTabNavigatorKey,
                pageBuilder: (context, state) {
                  return getPage(
                    child: GenerateHomeScreen(),
                    state: state,
                  );
                },
                // routes: [
                //   GoRoute(
                //     parentNavigatorKey: generateHomeTabNavigatorKey,
                //     path: AppPath.settings,
                //     name: PathName.nestedGenerateHomeSettings,
                //     builder: (context, state) => SettingsScreen(),
                //   )
                // ],
              ),
            ],
          ),
          StatefulShellBranch(navigatorKey: scanHomeTabNavigatorKey, routes: [
            GoRoute(
              path: AppPath.home,
              name: PathName.home,
              parentNavigatorKey: scanHomeTabNavigatorKey,
              pageBuilder: (context, state) {
                return getPage(
                  child: ScanHomeScreen(),
                  state: state,
                );
              },
            ),
          ]),
          StatefulShellBranch(navigatorKey: historyTabNavigatorKey, routes: [
            GoRoute(
              path: AppPath.history,
              name: PathName.history,
              parentNavigatorKey: historyTabNavigatorKey,
              pageBuilder: (context, state) {
                return getPage(
                  child: HistoryScreen(),
                  state: state,
                );
              },
              routes: [
                // GoRoute(
                //   path: AppPath.settings,
                //   name: PathName.nestedHistorySettings,
                //   parentNavigatorKey: historyTabNavigatorKey,
                //   builder: (context, state) => SettingsScreen(),
                // ),

                GoRoute(
                  path: AppPath.generatedQR,
                  name: PathName.generatedQR,
                  parentNavigatorKey: historyTabNavigatorKey,
                  pageBuilder: (context, state) {
                    return getPage(
                      child: GeneratedQRScreen(),
                      state: state,
                    );
                  },
                ),

                GoRoute(
                  path: AppPath.scannedQR,
                  name: PathName.scannedQR,
                  parentNavigatorKey: historyTabNavigatorKey,
                  pageBuilder: (context, state) {
                    return getPage(
                      child: ScannedQRScreen(),
                      state: state,
                    );
                  },
                ),
              ],
            ),
          ]),
        ],
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return getPage(
            child: BottomNavigationPage(
              navigationShell: navigationShell,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
          path: AppPath.splash,
          name: PathName.splash,
          builder: (context, state) => SplashScreen(),
          parentNavigatorKey: mainNavigatorKey),
      GoRoute(
          path: AppPath.onboarding,
          name: PathName.onboarding,
          builder: (context, state) => OnboardingScreen(),
          parentNavigatorKey: mainNavigatorKey),
      // GoRoute(
      //   path: AppPath.nestedGenerateHomeSettings,
      //   name: PathName.nestedGenerateHomeSettings,
      //   builder: (context, state) => SettingsScreen(),
      //   parentNavigatorKey: mainNavigatorKey,
      // ),
      // GoRoute(
      //   path: AppPath.nestedHistorySettings,
      //   name: PathName.nestedHistorySettings,
      //   builder: (context, state) => SettingsScreen(),
      //   parentNavigatorKey: mainNavigatorKey,
      // ),
      GoRoute(
        path: AppPath.settings,
        name: PathName.settings,
        builder: (context, state) => SettingsScreen(),
        parentNavigatorKey: mainNavigatorKey,
      ),

      GoRoute(
        path: AppPath.generateCode,
        name: PathName.generateCode,
        builder: (context, state) => GenerateHomeScreen(),
        parentNavigatorKey: mainNavigatorKey,
      ),
    ],
  );
  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }
}
