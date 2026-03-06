/// Compile-time configuration values injected via --dart-define flags.
///
/// Pass these at build time:
///   flutter run \
///     --dart-define=APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
///     --dart-define=APPWRITE_PROJECT_ID=your_project_id \
///     --dart-define=APPWRITE_PROJECT_NAME=your_project_name \
///     --dart-define=POSTHOG_API_KEY=phc_your_key \
///     --dart-define=POSTHOG_HOST=https://us.i.posthog.com
///
/// Or use the Makefile: `make run` (reads from .env file)
///
/// These values are supplied at build/run time via --dart-define flags
/// (for local development, loaded from .env by Makefile/launch configs).
class AppConfig {
  const AppConfig._();

  static const String _appwriteEndpointDefine = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: '',
  );

  // Backward-compatible alias for environments still using APPWRITE_URL.
  static const String _appwriteUrlDefine = String.fromEnvironment(
    'APPWRITE_URL',
    defaultValue: '',
  );

  static String get appwriteEndpoint {
    final raw = (_appwriteEndpointDefine.isNotEmpty
            ? _appwriteEndpointDefine
            : _appwriteUrlDefine)
        .trim();
    if (raw.isEmpty) return '';

    final sanitized =
        _stripWrappingQuotes(raw).replaceFirst(RegExp(r'/+$'), '');
    if (sanitized.isEmpty) return '';
    if (sanitized.endsWith('/v1')) return sanitized;
    return '$sanitized/v1';
  }

  static String? get appwriteConfigError {
    final endpoint = appwriteEndpoint;
    if (endpoint.isEmpty) {
      return 'Appwrite endpoint is missing. Pass APPWRITE_ENDPOINT '
          '(or APPWRITE_URL) via --dart-define.';
    }

    final uri = Uri.tryParse(endpoint);
    final validScheme = uri?.scheme == 'https' || uri?.scheme == 'http';
    if (uri == null || !uri.isAbsolute || !validScheme || uri.host.isEmpty) {
      return 'Invalid Appwrite endpoint "$endpoint". '
          'Expected a full URL like https://fra.cloud.appwrite.io/v1';
    }
    return null;
  }

  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '',
  );

  static const String appwriteProjectName = String.fromEnvironment(
    'APPWRITE_PROJECT_NAME',
    defaultValue: '',
  );

  static const String posthogApiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: '',
  );

  /// PostHog host — defaults to US cloud. Change to https://eu.i.posthog.com
  /// for EU cloud, or your self-hosted URL.
  static const String posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  );

  static String _stripWrappingQuotes(String value) {
    if (value.length < 2) return value;
    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
      return value.substring(1, value.length - 1).trim();
    }
    return value;
  }
}
