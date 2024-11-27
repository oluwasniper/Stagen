import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revolutionary_stuff/bottom_nav.dart';
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
    routeMethod(name: 'bottomnav', screen: BottomNavPage())
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




// class CustomNavigationHelper {
//   static final CustomNavigationHelper _instance =
//       CustomNavigationHelper._internal();

//   static CustomNavigationHelper get instance => _instance;

//   static late final GoRouter router;

//     static final GlobalKey<NavigatorState> splashNavigatorKey =
//       GlobalKey<NavigatorState>();

//             static final GlobalKey<NavigatorState> onboardingNavigatorKey =
//       GlobalKey<NavigatorState>();

//         static final GlobalKey<NavigatorState> mainNavigatorKey =
//       GlobalKey<NavigatorState>();

//             static final GlobalKey<NavigatorState> scanHomeTabNavigatorKey =
//       GlobalKey<NavigatorState>();

//             static final GlobalKey<NavigatorState> generateHomeTabNavigatorKey =
//       GlobalKey<NavigatorState>();

//             static final GlobalKey<NavigatorState> historyTabNavigatorKey =
//       GlobalKey<NavigatorState>();

  


//   // static final GlobalKey<NavigatorState> parentNavigatorKey =
//   //     GlobalKey<NavigatorState>();
//   // static final GlobalKey<NavigatorState> homeTabNavigatorKey =
//   //     GlobalKey<NavigatorState>();
//   // static final GlobalKey<NavigatorState> searchTabNavigatorKey =
//   //     GlobalKey<NavigatorState>();
//   // static final GlobalKey<NavigatorState> settingsTabNavigatorKey =
//   //     GlobalKey<NavigatorState>();

//   BuildContext get context =>
//       router.routerDelegate.navigatorKey.currentContext!;

//   GoRouterDelegate get routerDelegate => router.routerDelegate;

//   GoRouteInformationParser get routeInformationParser =>
//       router.routeInformationParser;



//       static const String splashPath = '/splash';
//   static const String onboardingPath = '/onboarding';
//   static const String homePath = '/home';
//   static const String generateHomePath = '/generateHome';
//   static const String historyPath = '/history';

//   // static const String signUpPath = '/signUp';
//   // static const String signInPath = '/signIn';
//   // static const String detailPath = '/detail';

//   // todo: remove this
//   static const String rootDetailPath = '/rootDetail';

//   // static const String homePath = '/home';
//   // static const String settingsPath = '/settings';
//   // static const String searchPath = '/search';

//   factory CustomNavigationHelper() {
//     return _instance;
//   }

//   CustomNavigationHelper._internal() {
//     final routes = [
//       StatefulShellRoute.indexedStack(
//         parentNavigatorKey: mainNavigatorKey,
//         branches: [
//           StatefulShellBranch(
//             navigatorKey: generateHomeTabNavigatorKey,
//             routes: [
//               GoRoute(
//                 path: generateHomePath,
//                 pageBuilder: (context, GoRouterState state) {
//                   return getPage(
//                     child: const GenerateHomeScreen(),
//                     state: state,
//                   );
//                 },
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             navigatorKey: scanHomeTabNavigatorKey,
//             routes: [
//               GoRoute(
//                 path: homePath,
//                 pageBuilder: (context, state) {
//                   return getPage(
//                     child: const ScanHomeScreen(),
//                     state: state,
//                   );
//                 },
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             navigatorKey: historyTabNavigatorKey,
//             routes: [
//               GoRoute(
//                 path: historyPath,
//                 pageBuilder: (context, state) {
//                   return getPage(
//                     child: const HistoryScreen(),
//                     state: state,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//         pageBuilder: (
//           BuildContext context,
//           GoRouterState state,
//           StatefulNavigationShell navigationShell,
//         ) {
//           return getPage(
//             child: BottomNavigationPage(
//               child: navigationShell,
//             ),
//             state: state,
//           );
//         },
//       ),
//       GoRoute(
//         parentNavigatorKey: parentNavigatorKey,
//         path: signUpPath,
//         pageBuilder: (context, state) {
//           return getPage(
//             child: const SignUpPage(),
//             state: state,
//           );
//         },
//       ),
//       GoRoute(
//         parentNavigatorKey: parentNavigatorKey,
//         path: signInPath,
//         pageBuilder: (context, state) {
//           return getPage(
//             child: const SignInPage(),
//             state: state,
//           );
//         },
//       ),
//       GoRoute(
//         path: detailPath,
//         pageBuilder: (context, state) {
//           return getPage(
//             child: const DetailPage(),
//             state: state,
//           );
//         },
//       ),
//       GoRoute(
//         parentNavigatorKey: parentNavigatorKey,
//         path: rootDetailPath,
//         pageBuilder: (context, state) {
//           return getPage(
//             child: const DetailPage(),
//             state: state,
//           );
//         },
//       ),
//     ];

//     router = GoRouter(
//       navigatorKey: parentNavigatorKey,
//       initialLocation: signUpPath,
//       routes: routes,
//     );
//   }

//   static Page getPage({
//     required Widget child,
//     required GoRouterState state,
//   }) {
//     return MaterialPage(
//       key: state.pageKey,
//       child: child,
//     );
//   }
// }