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

  /// WAWUBeauty monochrome light palette, bridged onto the legacy
  /// [AppThemeColors] field names so every screen still reading
  /// `context.appColors` inherits the WAWUBasket look without per-screen
  /// changes. `accent` maps to the near-black primary-action surface, and
  /// `onAccent` flips to white accordingly.
  static const light = AppThemeColors(
    background: Color(0xFFFFFFFF), // WBColors.bgPrimary
    surface: Color(0xFFFFFFFF), // WBColors.surfaceCard
    surfaceSecondary: Color(0xFFF7F7F7), // WBColors.bgSecondary
    surfaceElevated: Color(0xFFFFFFFF), // WBColors.surfaceCard
    textPrimary: Color(0xFF1A1A1A), // WBColors.fgHeader
    textSecondary: Color(0xFF4A4A4A), // WBColors.fgSecondary
    textTertiary: Color(0xFF7A7A7A), // WBColors.fgPlaceholder
    border: Color(0xFFE4E4E4), // WBColors.bgDivider
    borderStrong: Color(0xFFD4D4D4), // WBColors.borderFilled
    accent: Color(0xFF111111), // WBColors.surfaceDark
    accentSoft: Color(0xFFEFEFEF), // WBColors.bgSoft
    onAccent: Color(0xFFFFFFFF),
    iconBackground: Color(0xFFFFFFFF),
    shadow: Color(0x0A000000), // soft single-layer shadow
  );

  /// Dark intentionally mirrors [light]: WAWUBeauty is a light-mode-first
  /// app, so even if a dark path is requested the UI stays monochrome light.
  static const dark = light;

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
