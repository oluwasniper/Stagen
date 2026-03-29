import 'package:appwrite/appwrite.dart';
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

  AuthNotifier.misconfigured(String message, Ref ref)
      : _authService = _PlaceholderAuthService(message),
        _ref = ref,
        super(AuthState(status: AuthStatus.unauthenticated, error: message)) {
    initComplete = Future.value();
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
      // Always clear any stale local session first, then create fresh.
      await _authService.logout();
      try {
        await _authService.createAnonymousSession();
      } catch (e) {
        // If Appwrite still reports a session exists, force-clear and retry.
        if (appwriteErrorType(e) == 'user_session_already_exists') {
          await _authService.logout();
          await _authService.createAnonymousSession();
        } else {
          rethrow;
        }
      }
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

  /// Delete all user data and block the account, then sign out.
  ///
  /// Returns an error string if the operation fails, or null on success.
  Future<String?> deleteAccount() async {
    final user = state.user;
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // 1. Delete all user data first (while we still have a valid session).
      //    This covers QR records and in-app notification documents so that
      //    no PII lingers after the account is blocked (GDPR erasure).
      if (user != null) {
        final appwriteService = _ref.read(appwriteServiceProvider);
        await Future.wait([
          appwriteService.deleteAllUserData(user.$id),
          appwriteService.deleteAllUserNotifications(user.$id),
        ]);
      }

      // 2. Track deletion intent (errors here must not block the deletion).
      try {
        _telemetry.track(TelemetryEvents.authAccountDeleted);
      } catch (_) {}

      // 3. Block account + delete session.
      await _authService.blockAndDeleteAccount();

      // 4. Reset telemetry identity only after successful deletion.
      try {
        _telemetry.reset();
      } catch (_) {}

      // 5. Invalidate cached history.
      _ref.invalidate(scannedHistoryProvider);
      _ref.invalidate(generatedHistoryProvider);

      state = const AuthState(status: AuthStatus.unauthenticated);
      return null;
    } catch (e) {
      try {
        _telemetry.track(TelemetryEvents.authError,
            properties: {'error_type': appwriteErrorType(e) ?? 'unknown'});
      } catch (_) {}
      state = state.copyWith(
        status: AuthStatus.authenticated,
        error: e.toString(),
        errorType: appwriteErrorType(e),
      );
      return e.toString();
    }
  }

  /// Sign out and clear state.
  Future<void> signOut() async {
    final previousUser = state.user;
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      errorType: null,
    );

    try {
      _telemetry.track(TelemetryEvents.authSignout);
    } catch (_) {}

    try {
      await _authService.logout();
      try {
        _telemetry.reset();
      } catch (_) {}
      state = const AuthState(status: AuthStatus.unauthenticated);
      // Invalidate history providers so they re-fetch on next sign-in
      _ref.invalidate(scannedHistoryProvider);
      _ref.invalidate(generatedHistoryProvider);
    } catch (e) {
      try {
        _telemetry.track(
          TelemetryEvents.authError,
          properties: {'error_type': appwriteErrorType(e) ?? 'unknown'},
        );
      } catch (_) {}

      models.User? currentUser;
      try {
        currentUser = await _authService.getCurrentUser();
      } catch (_) {
        currentUser = previousUser;
      }
      state = AuthState(
        status: currentUser == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: currentUser ?? previousUser,
        error: e.toString(),
        errorType: appwriteErrorType(e),
      );
    }
  }
}

// ─── Placeholder (used when Appwrite is not configured) ───

class _PlaceholderAuthService extends AuthService {
  _PlaceholderAuthService(this._message) : super(client: Client());

  final String _message;

  StateError get _misconfiguredError => StateError(_message);

  @override
  Future<models.User?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<models.Session> createAnonymousSession() =>
      Future.error(_misconfiguredError);

  @override
  Future<models.User> createAccount({
    required String email,
    required String password,
    String? name,
  }) =>
      Future.error(_misconfiguredError);

  @override
  Future<models.Session> createEmailSession({
    required String email,
    required String password,
  }) =>
      Future.error(_misconfiguredError);

  @override
  Future<models.User> convertAnonymousToFull({
    required String email,
    required String password,
    String? name,
  }) =>
      Future.error(_misconfiguredError);
}

// ─── Provider ───

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  try {
    final authService = ref.watch(authServiceProvider);
    return AuthNotifier(authService, ref);
  } on StateError catch (e) {
    return AuthNotifier.misconfigured(e.message, ref);
  }
});
