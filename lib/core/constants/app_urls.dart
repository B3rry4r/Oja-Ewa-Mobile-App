import '../config/app_environment.dart';

/// Central place for backend base URLs.
///
/// Note: These can be overridden per-environment using dart-define:
/// - LARAVEL_BASE_URL
/// - AI_BASE_URL
class AppUrls {
  static const String _laravelOverride = String.fromEnvironment(
    'LARAVEL_BASE_URL',
    defaultValue: '',
  );
  static const String _aiOverride = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: '',
  );

  static String get laravelBaseUrl {
    if (_laravelOverride.isNotEmpty) return _laravelOverride;

    // Defaults (from docs):
    // - https://ojaewa-pro-api-production.up.railway.app
    switch (AppEnv.current) {
      case AppEnvironment.dev:
        return 'https://ojaewa-pro-api-production.up.railway.app';
      case AppEnvironment.staging:
        return 'https://ojaewa-pro-api-production.up.railway.app';
      case AppEnvironment.prod:
        return 'https://ojaewa-pro-api-production.up.railway.app';
    }
  }

  static String get aiBaseUrl {
    if (_aiOverride.isNotEmpty) return _aiOverride;

    // Defaults (from docs):
    // - https://ojaewa-ai-production.up.railway.app
    switch (AppEnv.current) {
      case AppEnvironment.dev:
        return 'https://ojaewa-ai-production.up.railway.app';
      case AppEnvironment.staging:
        return 'https://ojaewa-ai-production.up.railway.app';
      case AppEnvironment.prod:
        return 'https://ojaewa-ai-production.up.railway.app';
    }
  }
}
