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
}
