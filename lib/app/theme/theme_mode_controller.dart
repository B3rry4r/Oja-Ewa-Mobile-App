import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePreferenceKey = 'app_theme_mode';

final appThemeModeProvider =
    NotifierProvider<AppThemeModeController, ThemeMode>(
      AppThemeModeController.new,
    );

class AppThemeModeController extends Notifier<ThemeMode> {
  bool _hasLoaded = false;

  @override
  ThemeMode build() {
    if (!_hasLoaded) {
      _hasLoaded = true;
      _load();
    }
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModePreferenceKey);
    state = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModePreferenceKey, value);
  }

  Future<void> toggleLightDark() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }
}
