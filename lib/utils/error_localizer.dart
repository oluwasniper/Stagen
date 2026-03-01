import 'package:appwrite/appwrite.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extracts the Appwrite error `type` string from an exception, or `null` if
/// the exception is not an [AppwriteException].
String? appwriteErrorType(Object error) {
  if (error is AppwriteException) {
    return error.type;
  }
  return null;
}

/// Returns a user-friendly, localised message for the given Appwrite error
/// [type].  Falls back to [fallback] (or a generic message) when the type is
/// not recognised.
String localizeApiError(
  AppLocalizations l10n,
  String? type, [
  String? fallback,
]) {
  switch (type) {
    // ── Auth / User errors ──
    case 'user_already_exists':
      return l10n.apiErrorUserAlreadyExists;
    case 'user_invalid_credentials':
      return l10n.apiErrorInvalidCredentials;
    case 'user_blocked':
      return l10n.apiErrorUserBlocked;
    case 'user_not_found':
      return l10n.apiErrorUserNotFound;
    case 'user_email_already_exists':
      return l10n.apiErrorEmailAlreadyExists;
    case 'user_password_mismatch':
      return l10n.apiErrorPasswordMismatch;
    case 'user_session_already_exists':
      return l10n.apiErrorSessionAlreadyExists;
    case 'user_unauthorized':
      return l10n.apiErrorUnauthorized;
    case 'user_password_recently_used':
      return l10n.apiErrorPasswordRecentlyUsed;

    // ── Rate-limit ──
    case 'general_rate_limit_exceeded':
      return l10n.apiErrorRateLimitExceeded;

    // ── Network / server ──
    case 'general_server_error':
      return l10n.apiErrorServerError;

    default:
      return fallback ?? l10n.apiErrorUnknown;
  }
}
