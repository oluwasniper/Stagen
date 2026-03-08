import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/qr_record.dart';
import '../screens/auth_screen.dart';
import '../screens/generate_code_screen.dart';
import '../screens/open_file_screen.dart';
import '../screens/show_qr_screen.dart';
import '../bottom_nav.dart';
import '../screens/generate_home_screen.dart';
import '../screens/generated_qr_screen.dart';
import '../screens/history_screen.dart';
import '../screens/onboarding.dart';
import '../screens/scan_home_screen.dart';
import '../screens/scanned_qr_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/generate_qr_widget.dart';
import 'app_motion.dart';
import 'route/app_name.dart';
import 'route/app_path.dart';
import 'route/error_screen.dart';

class AppGoRouter {
  /// Returns the singleton instance of the app's [GoRouter].
  ///
  /// This getter provides access to the centralized routing configuration
  /// for the application. The router is implemented as a singleton to ensure
  /// consistent navigation state throughout the app.
  static GoRouter get router => _router;

  /// A global key used to uniquely identify and manage the main Navigator state.
  ///
  /// This key is essential for navigation operations throughout the app, allowing
  /// access to the Navigator's state from anywhere in the widget tree.
  /// It enables pushing/popping routes and other navigation actions without
  /// requiring a direct BuildContext.
  ///
  /// Example usage:
  /// ```dart
  /// AppRouter.mainNavigatorKey.currentState?.pushNamed('/home');
  /// ```
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

  /// Returns the current [BuildContext] for this router.
  ///
  /// The [BuildContext] is essential for navigation and accessing the widget tree.
  /// This getter provides access to the context that can be used for routing
  /// operations and widget-related functionality.
  ///
  /// Throws a [StateError] if accessed when no valid context is available.
  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  /// Returns the [GoRouterDelegate] instance associated with the router.
  ///
  /// This getter provides access to the router delegate, which is responsible for
  /// building the navigator and handling routing state within the application.
  /// The delegate manages the routing stack and handles platform integration
  /// like deep linking and browser history.
  GoRouterDelegate get routerDelegate => router.routerDelegate;

  /// Gets the route information parser for Go Router.
  ///
  /// Returns a [GoRouteInformationParser] instance that handles parsing URL paths
  /// and query parameters into route information objects and vice versa. This is a
  /// core component for navigation in the Go Router system.
  ///
  /// The parser is responsible for:
  /// - Converting URLs into route information objects
  /// - Converting route information objects back into URLs
  /// - Handling path parameters and query parameters parsing
  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static final GoRouter _router = GoRouter(
    /// debugLogDiagnostics: true, will print the diagnostics in the console
    debugLogDiagnostics: false,

    /// The global navigation key for the app's main navigator.
    /// This key allows navigation actions to be performed from anywhere in the app
    /// without requiring a BuildContext.
    ///
    /// Usage:
    /// ```dart
    /// mainNavigatorKey.currentState?.push(...);
    /// ```
    navigatorKey: mainNavigatorKey,

    /// The initial route path for the app router.
    ///
    /// This specifies the first screen that users see when launching the app.
    /// In this case, it directs to the splash screen defined in [AppPath.splash].
    initialLocation: AppPath.splash,

    /// Returns an [ErrorScreen] widget when navigation errors occur.
    /// This is the fallback screen shown to users when a route cannot be found
    /// or when there is a navigation error.
    ///
    /// Parameters:
    /// - [context]: The build context
    /// - [state]: The error state containing navigation error details
    ///
    /// Example Usage:
    /// ```
    /// GoRouter(
    ///   errorBuilder: (context, state) => ErrorScreen(),
    /// )
    /// ```
    errorBuilder: (context, state) => ErrorScreen(),

    /// Application routing configuration
    ///
    /// Defines a collection of routes that map URLs to their corresponding screens
    /// or pages within the application. Each route in this list represents a unique
    /// path and its associated widget.
    ///
    /// Example:
    /// ```dart
    /// routes: [
    ///   GoRoute(
    ///     path: '/',
    ///     builder: (context, state) => HomeScreen(),
    ///   ),
    /// ]
    /// ```
    ///
    /// This routing system is built using the go_router package for declarative
    /// routing in Flutter applications.
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: mainNavigatorKey,
        builder: (context, state, navigationShell) {
          return BottomNavigationPage(
            navigationShell: navigationShell,
          );
        },
        branches: [
          /// A node in the navigation hierarchy that maintains state across navigations.
          /// StatefulShellBranch represents a distinct navigational path/branch in a stateful shell navigation setup.
          /// It enables persistent state management and view preservation when switching between different navigation branches.
          ///
          /// Typically used in bottom navigation bar or similar multi-tab navigation patterns where each tab
          /// maintains its own navigation history and state.
          StatefulShellBranch(
            navigatorKey: generateHomeTabNavigatorKey,
            routes: [
              /// A route configuration for the generate home tab.
              GoRoute(
                path: AppPath.generateHome,
                name: PathName.generateHome,
                parentNavigatorKey: generateHomeTabNavigatorKey,
                pageBuilder: (context, state) {
                  /// Returns a constructed page based on specified routing parameters.
                  ///
                  /// This method is responsible for routing and page construction within the app.
                  /// It processes the route configuration and returns the appropriate page widget.
                  ///
                  /// @returns A widget representing the requested page
                  return getPage(
                    child: GenerateHomeScreen(),
                    state: state,
                  );
                },
                routes: [
                  GoRoute(
                    path: AppPath.generateCodeSegment,
                    name: PathName.generateCode,
                    parentNavigatorKey: generateHomeTabNavigatorKey,
                    pageBuilder: (context, state) => getPage(
                      child: _buildGenerateCodeScreen(context, state),
                      state: state,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// A shell branch configuration for the scan home tab.
          ///
          /// Uses [scanHomeTabNavigatorKey] as the navigator key for managing navigation state
          /// within this branch. Contains the routes specific to the scanning functionality
          /// section of the app.
          ///
          /// This branch is part of a StatefulShell navigation structure, allowing for
          /// persistent navigation state maintenance within the scan tab.
          StatefulShellBranch(navigatorKey: scanHomeTabNavigatorKey, routes: [
            /// A route configuration for the scan home tab.
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
            /// A route configuration for the history tab.
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

                /// A route configuration for the generated QR code screen.
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

                /// A route configuration for the scanned QR code screen.
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

                /// A route configuration for the open file screen.
                GoRoute(
                  path: AppPath.openFile,
                  name: PathName.openFile,
                  pageBuilder: (context, state) {
                    final record = state.extra as QRRecord?;
                    return getPage(
                        child: OpenFileScreen(record: record), state: state);
                  },
                  parentNavigatorKey: historyTabNavigatorKey,
                ),

                /// A route configuration for the show QR screen.
                GoRoute(
                  path: AppPath.showQR,
                  name: PathName.showQR,
                  parentNavigatorKey: historyTabNavigatorKey,
                  pageBuilder: (context, state) {
                    final record = state.extra as QRRecord?;
                    return getPage(
                      child: ShowQrScreen(record: record),
                      state: state,
                    );
                  },
                ),
              ],
            ),
          ]),
        ],

        /// Builds and returns the actual page/screen widget for this route.
        ///
        /// The method receives the current [BuildContext], [GoRouterState],
        /// and an optional [Object] parameter representing extra data passed during navigation.
        ///
        /// This callback is used by GoRouter to construct the appropriate widget
        /// when navigating to this route.
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          /// Returns a page widget based on configuration
          ///
          /// This method is responsible for generating and returning the appropriate page widget
          /// based on the provided navigation settings or parameters. It serves as a routing
          /// utility within the application's navigation system.
          return getPage(
            child: BottomNavigationPage(
              navigationShell: navigationShell,
            ),
            state: state,
          );
        },
      ),

      /// A route configuration for the splash screen.
      GoRoute(
        path: AppPath.splash,
        name: PathName.splash,
        pageBuilder: (context, state) => getPage(
          child: SplashScreen(),
          state: state,
        ),
        parentNavigatorKey: mainNavigatorKey,
      ),

      /// A route configuration for the onboarding screen.
      GoRoute(
        path: AppPath.onboarding,
        name: PathName.onboarding,
        pageBuilder: (context, state) => getPage(
          child: OnboardingScreen(),
          state: state,
        ),
        parentNavigatorKey: mainNavigatorKey,
      ),

      /// A route configuration for the auth screen.
      GoRoute(
        path: AppPath.auth,
        name: PathName.auth,
        pageBuilder: (context, state) => getPage(
          child: const AuthScreen(),
          state: state,
        ),
        parentNavigatorKey: mainNavigatorKey,
      ),
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

      /// A route configuration for the settings screen.
      GoRoute(
        path: AppPath.settings,
        name: PathName.settings,
        pageBuilder: (context, state) => getPage(
          child: SettingsScreen(),
          state: state,
        ),
        parentNavigatorKey: mainNavigatorKey,
      ),

      /// Legacy deep-link support for old /generateCode path.
      GoRoute(
        path: AppPath.generateCodeLegacy,
        redirect: (_, __) => AppPath.generateCode,
      ),

      /// A route configuration for the generated QR result screen.
      GoRoute(
        path: AppPath.generatedQRResult,
        name: PathName.generatedQRResult,
        pageBuilder: (context, state) => getPage(
          child: GeneratedQRScreen(),
          state: state,
        ),
        parentNavigatorKey: mainNavigatorKey,
      ),

      /// A route configuration for the scanned QR result screen.
      GoRoute(
        path: AppPath.scannedQRResult,
        name: PathName.scannedQRResult,
        pageBuilder: (context, state) => getPage(
          child: ScannedQRScreen(),
          state: state,
        ),
        parentNavigatorKey: mainNavigatorKey,
      ),
    ],
  );

  static Widget _buildGenerateCodeScreen(
      BuildContext context, GoRouterState state) {
    final extra = state.extra;
    QROption type;
    Map<String, String>? initialValues;

    if (extra is QROption) {
      type = extra;
    } else if (extra is Map) {
      final typeName = extra['type']?.toString();
      final qrType = QROptionType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => QROptionType.text,
      );
      type = QROptions.fromType(context, qrType);

      final rawPrefill = extra['prefill'];
      if (rawPrefill is Map) {
        initialValues = rawPrefill.map(
          (key, value) => MapEntry(
            key.toString(),
            value?.toString() ?? '',
          ),
        );
      }
    } else {
      type = QROptions.fromType(context, QROptionType.text);
    }

    return GenerateCodeScreen(
      type: type,
      initialValues: initialValues,
    );
  }

  /// Returns a [Page] based on the provided parameters.
  ///
  /// This static method generates and returns the appropriate page for navigation
  /// within the application. It's responsible for creating the correct page instance
  /// based on the given configuration.
  ///
  /// @return A [Page] instance that can be used in the navigation stack.
  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    const transitionDuration = AppMotion.slow;
    const reverseTransitionDuration = AppMotion.medium;

    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final disableAnimations = (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);
        if (disableAnimations) return child;

        final platform = Theme.of(context).platform;
        final isCupertinoPlatform =
            platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

        if (isCupertinoPlatform) {
          final primary = CurvedAnimation(
            parent: animation,
            curve: AppMotion.emphasized,
            reverseCurve: AppMotion.exit,
          );
          final secondary = CurvedAnimation(
            parent: secondaryAnimation,
            curve: AppMotion.emphasized,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(primary),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.03, 0),
              ).animate(secondary),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.92, end: 1.0).animate(primary),
                child: child,
              ),
            ),
          );
        }

        // Spring-style forward curve (fast out, then settle)
        final forwardCurved = CurvedAnimation(
          parent: animation,
          curve: const _SpringCurve(),
          reverseCurve: AppMotion.exit,
        );

        // Secondary animation: outgoing screen fades and scales slightly
        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: AppMotion.exit,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(forwardCurved),
          child: FadeTransition(
            opacity:
                Tween<double>(begin: 1.0, end: 0.92).animate(secondaryCurved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.055, 0),
                end: Offset.zero,
              ).animate(forwardCurved),
              child: ScaleTransition(
                scale:
                    Tween<double>(begin: 0.97, end: 1.0).animate(forwardCurved),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Approximates iOS spring physics: fast start, gentle overshoot, smooth settle.
class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Cubic bezier approximation of a spring: fast out, tiny overshoot, settle
    // Equivalent to cubic-bezier(0.34, 1.56, 0.64, 1) from CSS springs
    return _cubicBezier(t, 0.34, 1.56, 0.64, 1.0);
  }

  /// Evaluates a cubic bezier at parameter [t] using numerical solve.
  static double _cubicBezier(
      double t, double x1, double y1, double x2, double y2) {
    double cx = 3 * x1;
    double bx = 3 * (x2 - x1) - cx;
    double ax = 1 - cx - bx;

    double cy = 3 * y1;
    double by = 3 * (y2 - y1) - cy;
    double ay = 1 - cy - by;

    // Solve for u such that bezierX(u) == t
    double u = t;
    for (int i = 0; i < 4; i++) {
      double x = ((ax * u + bx) * u + cx) * u - t;
      double dx = (3 * ax * u + 2 * bx) * u + cx;
      if (dx.abs() < 1e-6) break;
      u -= x / dx;
    }
    u = u.clamp(0.0, 1.0);
    return ((ay * u + by) * u + cy) * u;
  }
}
