import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    // GoRoute(
    //   path: '/',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const ProductListingScreen(),
    // ),
    // GoRoute(
    //   path: '/home',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const ProductListingScreen(),
    // ),
    // GoRoute(
    //   // path: '/auth',
    //   path: '/',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const AuthScreen(),
    // ),
    // GoRoute(
    //   path: '/sign-up',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const SignUpScreen(),
    // ),
    // GoRoute(
    //   path: '/product-details/:productId',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       ProductDetailsScreen(
    //     productId: int.parse(state.pathParameters['productId']!),
    //   ),
    // ),
    // GoRoute(
    //   path: '/home',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const ProfileScreen(),
    // ),
    // GoRoute(
    //   path: '/profile',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const ProfileScreen(),
    // ),
    // GoRoute(
    //   path: '/favorites',
    //   builder: (BuildContext context, GoRouterState state) =>
    //       const FavoritesScreen(),
    // ),
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

GoRouter get router => _router;
