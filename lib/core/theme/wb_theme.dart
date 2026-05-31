import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'wb_colors.dart';
import 'wb_typography.dart';

/// Builds a light-mode-first Material ThemeData seeded by WAWUBasket tokens.
///
/// Most components are bespoke widgets that consume tokens directly. This theme
/// exists to harmonize default Flutter widgets (e.g. ScaffoldMessenger snack
/// bars, default cursor color) with the system.
ThemeData buildWBTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: WBColors.bgPrimary,
    primaryColor: WBColors.surfaceDark,
    colorScheme: const ColorScheme.light(
      primary: WBColors.surfaceDark,
      onPrimary: Colors.white,
      secondary: WBColors.fgHeader,
      onSecondary: Colors.white,
      surface: WBColors.surfaceCard,
      onSurface: WBColors.fgPrimary,
      error: WBColors.statusError,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.albertSansTextTheme().apply(
      bodyColor: WBColors.fgPrimary,
      displayColor: WBColors.fgHeader,
    ),
    splashFactory: InkRipple.splashFactory,
  );

  return base.copyWith(
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: WBColors.fgHeader,
      selectionColor: Color(0x33111111),
      selectionHandleColor: WBColors.fgHeader,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: WBColors.bgPrimary,
      foregroundColor: WBColors.fgHeader,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: WBTypography.cardTitle,
    ),
  );
}
