import 'package:flutter/material.dart';

import 'app_theme_colors.dart';

/// App-wide theming.
///
/// Keep this file stable and build on it over time (color scheme, typography,
/// component themes, etc).
abstract class AppTheme {
  static ThemeData light() {
    const colors = AppThemeColors.light;
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFDAF40),
      onPrimary: Color(0xFF111111),
      secondary: Color(0xFFFDAF40),
      onSecondary: Color(0xFF111111),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF111111),
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Campton',
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.border,
      extensions: const [colors],
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFDAF40),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(color: colors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
    );
  }

  static ThemeData dark() {
    const colors = AppThemeColors.dark;
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFDAF40),
      onPrimary: Color(0xFF111111),
      secondary: Color(0xFFFDAF40),
      onSecondary: Color(0xFF111111),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF111111),
      onSurface: Color(0xFFF7F7F7),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Campton',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.border,
      extensions: const [colors],
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFDAF40),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(color: colors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
    );
  }
}
