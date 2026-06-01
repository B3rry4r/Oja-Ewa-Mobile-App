import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's chosen [Locale] and persists it across launches.
/// A null value means "follow the device locale".
class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _kLocale = 'wawubeauty.locale';

  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// Loads the saved locale. Call once at app boot.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLocale);
      if (code != null && code.isNotEmpty) locale.value = Locale(code);
    } catch (_) {
      // SharedPreferences unavailable — fall back to the device locale.
    }
  }

  /// Switches the app language and persists the choice.
  Future<void> setLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocale, languageCode);
    } catch (_) {
      // Persisting failed — the choice still applies for this session.
    }
  }
}
