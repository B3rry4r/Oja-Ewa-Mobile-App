import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.iconBackground,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderStrong;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color iconBackground;
  final Color shadow;

  static const light = AppThemeColors(
    background: Color(0xFFF7F4EF),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF1ECE4),
    surfaceElevated: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF4C4C4C),
    textTertiary: Color(0xFF7A7A7A),
    border: Color(0xFFE0DED9),
    borderStrong: Color(0xFFB9B3A9),
    accent: Color(0xFFFDAF40),
    accentSoft: Color(0xFFFFE4B8),
    onAccent: Color(0xFF111111),
    iconBackground: Color(0xFFFFFFFF),
    shadow: Color(0x14000000),
  );

  static const dark = AppThemeColors(
    background: Color(0xFF050505),
    surface: Color(0xFF111111),
    surfaceSecondary: Color(0xFF181818),
    surfaceElevated: Color(0xFF1D1D1D),
    textPrimary: Color(0xFFF7F7F7),
    textSecondary: Color(0xFFD0D0D0),
    textTertiary: Color(0xFFA0A0A0),
    border: Color(0xFF2A2A2A),
    borderStrong: Color(0xFF494949),
    accent: Color(0xFFFDAF40),
    accentSoft: Color(0xFF4B3210),
    onAccent: Color(0xFF111111),
    iconBackground: Color(0xFF141414),
    shadow: Color(0x66000000),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderStrong,
    Color? accent,
    Color? accentSoft,
    Color? onAccent,
    Color? iconBackground,
    Color? shadow,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      iconBackground: iconBackground ?? this.iconBackground,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppThemeColorsBuildContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}
