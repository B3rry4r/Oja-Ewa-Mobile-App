/// App runtime environment configuration.
///
/// For now this is compile-time via `--dart-define=APP_ENV=...`.
///
/// Examples:
/// - flutter run --dart-define=APP_ENV=dev
/// - flutter run --dart-define=APP_ENV=prod
enum AppEnvironment {
  dev,
  staging,
  prod,
}

class AppEnv {
  static const String _envValue = String.fromEnvironment('APP_ENV', defaultValue: 'prod');

  static AppEnvironment get current {
    switch (_envValue.toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      default:
        return AppEnvironment.prod;
    }
  }

  // Pusher configuration
  static const String pusherKey = String.fromEnvironment(
    'PUSHER_KEY',
    defaultValue: 'baf71c0a8ff3c3efb08b',
  );

  static const String pusherCluster = String.fromEnvironment(
    'PUSHER_CLUSTER',
    defaultValue: 'mt1',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ojaewa-pro-api-production-2254.up.railway.app',
  );

  static String get pusherAuthEndpoint => '$apiBaseUrl/broadcasting/auth';

  // Access token storage for Pusher authorization
  static String? accessToken;
}
