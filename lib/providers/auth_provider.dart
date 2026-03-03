import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../utils/error_localizer.dart';
import 'qr_providers.dart';

// ─── Auth Service Provider ───

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return AuthService(client: client);
});

// ─── Auth State ───

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final models.User? user;
  final String? error;

  /// The Appwrite error type (e.g. 'user_already_exists') for localisation.
  final String? errorType;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
    this.errorType,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAnonymous => user != null && user!.email.isEmpty;

  AuthState copyWith({
    AuthStatus? status,
    models.User? user,
    String? error,
    String? errorType,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      errorType: errorType,
    );
  }
}

// ─── Auth Notifier ───

class AuthNotifier extends StateNotifier<AuthState> {
  /// Link anonymous account to email/password.
  Future<void> linkAnonymousAccount({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.convertAnonymousToFull(
          email: email, password: password, name: name);
      // After linking, fetch the updated user
      final user = await _authService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      try {
        _telemetry.track(TelemetryEvents.authAccountLinked);
      } catch (_) {}
    } catch (e) {
      try {
        _telemetry.track(TelemetryEvents.authError,
            properties: {'error_type': appwriteErrorType(e) ?? 'unknown'});
      } catch (_) {}
      state = state.copyWith(
        status: AuthStatus.authenticated, // Still authenticated, but show error
        error: e.toString(),
        errorType: appwriteErrorType(e),
      );
    }
  }

  final AuthService _authService;
  final Ref _ref;
  late final Future<void> initComplete;

  AuthNotifier(this._authService, this._ref)
      : super(const AuthState(status: AuthStatus.loading)) {
    initComplete = _init();
  }

  TelemetryService get _telemetry => _ref.read(telemetryServiceProvider);

  /// Check for existing session on startup.
  Future<void> _init() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
      _telemetry.identify(user.$id);
      _telemetry.track(TelemetryEvents.sessionResumed);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Continue without account (anonymous session).
  Future<void> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Always clear any stale local session first, then create fresh
      await _authService.logout();
      await _authService.createAnonymousSession();
      final user = await _authService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      try {
        if (user != null) _telemetry.identify(user.$id);
        _telemetry.track(TelemetryEvents.authSigninAnonymous);
      } catch (_) {}
    } catch (e) {
      try {
        _telemetry.track(TelemetryEvents.authError,
            properties: {'error_type': appwriteErrorType(e) ?? 'unknown'});
      } catch (_) {}
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
        errorType: appwriteErrorType(e),
      );
    }
  }

  /// Create a new account and sign in.
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.createAccount(
        email: email,
        password: password,
        name: name,
      );
      await _authService.createEmailSession(
        email: email,
        password: password,
      );
      final user = await _authService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      try {
        if (user != null) _telemetry.identify(user.$id);
        _telemetry.track(TelemetryEvents.authSignupEmail);
      } catch (_) {}
    } catch (e) {
      try {
        _telemetry.track(TelemetryEvents.authError,
            properties: {'error_type': appwriteErrorType(e) ?? 'unknown'});
      } catch (_) {}
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
        errorType: appwriteErrorType(e),
      );
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.createEmailSession(
        email: email,
        password: password,
      );
      final user = await _authService.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      try {
        if (user != null) _telemetry.identify(user.$id);
        _telemetry.track(TelemetryEvents.authSigninEmail);
      } catch (_) {}
    } catch (e) {
      try {
        _telemetry.track(TelemetryEvents.authError,
            properties: {'error_type': appwriteErrorType(e) ?? 'unknown'});
      } catch (_) {}
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
        errorType: appwriteErrorType(e),
      );
    }
  }

  /// Sign out and clear state.
  Future<void> signOut() async {
    _telemetry.track(TelemetryEvents.authSignout);
    await _authService.logout();
    try {
      _telemetry.reset();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
    // Invalidate history providers so they re-fetch on next sign-in
    _ref.invalidate(scannedHistoryProvider);
    _ref.invalidate(generatedHistoryProvider);
  }
}

// ─── Provider ───

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
