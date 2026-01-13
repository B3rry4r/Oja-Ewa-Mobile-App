import 'package:flutter/material.dart';

/// App-wide theming.
///
/// Keep this file stable and build on it over time (color scheme, typography,
/// component themes, etc).
abstract class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      // Default typography for the whole app.
      fontFamily: 'Campton',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFDAF40)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFDAF40),
      ),
    );

    return base;
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Default typography for the whole app.
      fontFamily: 'Campton',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFDAF40),
        brightness: Brightness.dark,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFDAF40),
      ),
    );

    return base;
  }
}
