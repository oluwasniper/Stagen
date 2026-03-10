import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

/// Service class for authentication using Appwrite.
///
/// Supports both anonymous sessions (device-scoped, no sign-in required)
/// and full email/password authentication (cross-device sync).
class AuthService {
  final Account _account;

  AuthService({required Client client}) : _account = Account(client);

  bool _isNoActiveSessionError(Object error) {
    if (error is! AppwriteException) return false;
    return error.code == 401 ||
        error.type == 'user_unauthorized' ||
        error.type == 'general_unauthorized_scope';
  }

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
      return;
    } catch (error) {
      // If there is no active session, we're already signed out.
      if (_isNoActiveSessionError(error)) return;

      // Fallback: try deleting all sessions.
      try {
        await _account.deleteSessions();
        return;
      } catch (fallbackError) {
        // If fallback says there is no active session, treat as success.
        if (_isNoActiveSessionError(fallbackError)) return;
        rethrow;
      }
    }
  }
}
