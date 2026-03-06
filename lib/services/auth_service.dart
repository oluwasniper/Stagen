import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

/// Service class for authentication using Appwrite.
///
/// Supports both anonymous sessions (device-scoped, no sign-in required)
/// and full email/password authentication (cross-device sync).
class AuthService {
  final Account _account;

  AuthService({required Client client}) : _account = Account(client);

  // ─── Session Management ───

  /// Get the currently logged-in user, or `null` if there is no active session.
  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (_) {
      return null;
    }
  }

  /// Check whether the current session is anonymous.
  ///
  /// An anonymous user has no email.
  bool isAnonymous(models.User user) {
    return user.email.isEmpty;
  }

  // ─── Anonymous Auth ───

  /// Create an anonymous session so the user can interact with the backend
  /// without providing credentials. Records will be tied to this device session.
  Future<models.Session> createAnonymousSession() async {
    return await _account.createAnonymousSession();
  }

  // ─── Email / Password Auth ───

  /// Register a new account with email, password, and optional name.
  Future<models.User> createAccount({
    required String email,
    required String password,
    String? name,
  }) async {
    return await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  /// Sign in with email and password.
  Future<models.Session> createEmailSession({
    required String email,
    required String password,
  }) async {
    return await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  /// Convert an anonymous session to a full account by adding
  /// email and password credentials.
  Future<models.User> convertAnonymousToFull({
    required String email,
    required String password,
    String? name,
  }) async {
    // Update email
    await _account.updateEmail(email: email, password: password);
    // Optionally update name
    if (name != null && name.isNotEmpty) {
      await _account.updateName(name: name);
    }
    return await _account.get();
  }

  // ─── Sign Out ───

  /// Delete the current session (sign out).
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // Session may already be expired / deleted; try deleting all sessions
      // as a fallback to ensure we're fully signed out.
      try {
        await _account.deleteSessions();
      } catch (_) {}
    }
  }
}
