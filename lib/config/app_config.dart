/// Compile-time configuration values injected via --dart-define flags.
///
/// Pass these at build time:
///   flutter run \
///     --dart-define=APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
///     --dart-define=APPWRITE_PROJECT_ID=your_project_id \
///     --dart-define=POSTHOG_API_KEY=phc_your_key \
///     --dart-define=POSTHOG_HOST=https://us.i.posthog.com
///
/// Or use the Makefile: `make run` (reads from .env file)
///
/// Default values are intentionally empty strings so the app does not crash
/// at runtime when dart-defines are omitted (e.g. in unit tests).
class AppConfig {
  const AppConfig._();

  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: '',
  );

  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
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
}
