import 'package:flutter/material.dart';

/// WAWUBasket monochrome color palette.
///
/// Sourced from the design system at `design_assets/wawubasket-design-system/
/// project/colors_and_type.css`. Status colors are the only sanctioned accents.
abstract final class WBColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF7F7F7);
  static const Color bgSoft = Color(0xFFEFEFEF);
  static const Color bgDivider = Color(0xFFE4E4E4);

  // Text
  static const Color fgPrimary = Color(0xFF000000);
  static const Color fgHeader = Color(0xFF1A1A1A);
  static const Color fgSecondary = Color(0xFF4A4A4A);
  static const Color fgPlaceholder = Color(0xFF7A7A7A);
  static const Color fgDisabled = Color(0xFFA0A0A0);

  // Surfaces
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF111111);
  // Input fill — visibly distinct from both bgPrimary (#FFFFFF) and
  // bgSecondary (#F7F7F7) so empty inputs never blend into the page.
  static const Color surfaceInput = Color(0xFFEEEEEE);
  static const Color surfaceTag = Color(0xFFF1F1F1);

  // Borders (focus / filled state)
  static const Color borderFilled = Color(0xFFD4D4D4);

  // Status — sanctioned accent colors
  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusError = Color(0xFFEF4444);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusInfo = Color(0xFF3B82F6);

  // Status text-on-tint pairings (matches the design previews).
  static const Color statusSuccessFg = Color(0xFF15803D);
  static const Color statusErrorFg = Color(0xFFB91C1C);
  static const Color statusWarningFg = Color(0xFFB45309);
  static const Color statusInfoFg = Color(0xFF1D4ED8);
}
