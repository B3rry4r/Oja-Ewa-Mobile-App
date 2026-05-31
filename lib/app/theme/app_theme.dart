import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_colors.dart';
import '../../core/theme/wb_theme_exports.dart';

/// App-wide theming.
///
/// WAWUBeauty is a light-mode-first, monochrome app that mirrors the
/// WAWUBasket design system. Both [light] and [dark] return the same light
/// theme so the app never renders a dark surface, regardless of the requested
/// [ThemeMode]. The legacy [AppThemeColors] extension is still attached so
/// screens reading `context.appColors` keep working.
abstract class AppTheme {
  static ThemeData light() => _build();
  static ThemeData dark() => _build();

  static ThemeData _build() {
    const colors = AppThemeColors.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: WBColors.bgPrimary,
      primaryColor: WBColors.surfaceDark,
      dividerColor: WBColors.bgDivider,
      extensions: const [colors],
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: WBColors.surfaceDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: WBColors.bgPrimary,
        foregroundColor: WBColors.fgHeader,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: WBTypography.cardTitle,
      ),
      cardTheme: CardThemeData(
        color: WBColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WBRadius.card),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(color: WBColors.fgPlaceholder),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WBColors.fgHeader,
          side: const BorderSide(color: WBColors.borderFilled),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WBRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WBColors.surfaceDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WBRadius.button),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: WBColors.fgHeader,
        selectionColor: Color(0x33111111),
        selectionHandleColor: WBColors.fgHeader,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: WBColors.fgPrimary,
        displayColor: WBColors.fgHeader,
      ),
    );
  }
}
