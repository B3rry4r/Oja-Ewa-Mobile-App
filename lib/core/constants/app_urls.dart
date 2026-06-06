import '../config/app_environment.dart';

/// Base URL of the WAWUAfrica hub web platform.
///
/// Configurable via dart-define `WAWUAFRICA_HUB_URL`. Used to deep-link from
/// the home services row into the hub's service pages (EasyBuy, Insurance,
/// Pension, etc.).
// Production fallback used whenever the dart-define is absent OR resolves to an
// empty string (e.g. the web CI passes `--dart-define=WAWUAFRICA_HUB_URL=` when
// the secret is unset, which makes String.fromEnvironment return "" and bypass
// `defaultValue`). Resolving at runtime guarantees a usable URL on web too.
const String _wawuAfricaHubUrlEnv = String.fromEnvironment('WAWUAFRICA_HUB_URL', defaultValue: '');
const String _wawuAfricaHubUrlFallback = 'https://wawuafrica-new-production.up.railway.app';

String get wawuAfricaHubUrl =>
    _wawuAfricaHubUrlEnv.isNotEmpty ? _wawuAfricaHubUrlEnv : _wawuAfricaHubUrlFallback;

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
    // - https://ojaewa-pro-api-production-2254.up.railway.app
    switch (AppEnv.current) {
      case AppEnvironment.dev:
        return 'https://ojaewa-pro-api-production-2254.up.railway.app';
      case AppEnvironment.staging:
        return 'https://ojaewa-pro-api-production-2254.up.railway.app';
      case AppEnvironment.prod:
        return 'https://ojaewa-pro-api-production-2254.up.railway.app';
    }
  }

  static String get wawuIdBaseUrl {
    const override = String.fromEnvironment('WAWU_ID_BASE_URL', defaultValue: '');
    return override.isNotEmpty ? override : 'https://wawu-id-production.up.railway.app';
  }

  static String get aiBaseUrl {
    if (_aiOverride.isNotEmpty) return _aiOverride;

    // Defaults (from docs):
    // - https://ojaewa-ai-production-1bb8.up.railway.app
    switch (AppEnv.current) {
      case AppEnvironment.dev:
        return 'https://ojaewa-ai-production-1bb8.up.railway.app';
      case AppEnvironment.staging:
        return 'https://ojaewa-ai-production-1bb8.up.railway.app';
      case AppEnvironment.prod:
        return 'https://ojaewa-ai-production-1bb8.up.railway.app';
    }
  }
}
