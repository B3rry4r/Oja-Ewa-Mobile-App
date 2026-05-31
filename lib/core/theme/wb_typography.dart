import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'wb_colors.dart';

/// Albert Sans type scale, semantic styles, and weight tokens.
abstract final class WBTypography {
  static TextStyle _albert({
    required double fontSize,
    required FontWeight weight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) =>
      GoogleFonts.albertSans(
        fontSize: fontSize,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? WBColors.fgPrimary,
      );

  // Hero — 32px SemiBold, tight tracking
  static TextStyle hero = _albert(
    fontSize: 32,
    weight: FontWeight.w600,
    letterSpacing: -0.64, // -0.02em
    height: 1.15,
    color: WBColors.fgHeader,
  );

  // Page title — 24px SemiBold
  static TextStyle page = _albert(
    fontSize: 24,
    weight: FontWeight.w600,
    letterSpacing: -0.36, // -0.015em
    height: 1.2,
    color: WBColors.fgHeader,
  );

  // Section title — 20px Medium
  static TextStyle section = _albert(
    fontSize: 20,
    weight: FontWeight.w500,
    letterSpacing: -0.20, // -0.01em
    height: 1.25,
    color: WBColors.fgHeader,
  );

  // Card title — 18px Medium
  static TextStyle cardTitle = _albert(
    fontSize: 18,
    weight: FontWeight.w500,
    height: 1.3,
    color: WBColors.fgHeader,
  );

  // Body — 16px Regular
  static TextStyle body = _albert(
    fontSize: 16,
    weight: FontWeight.w400,
    height: 1.5,
    color: WBColors.fgPrimary,
  );

  // Secondary — 14px Regular
  static TextStyle secondary = _albert(
    fontSize: 14,
    weight: FontWeight.w400,
    height: 1.45,
    color: WBColors.fgSecondary,
  );

  // Caption — 12px Regular
  static TextStyle caption = _albert(
    fontSize: 12,
    weight: FontWeight.w400,
    height: 1.4,
    color: WBColors.fgSecondary,
  );

  // Small label — 11px Medium, uppercase
  static TextStyle label = _albert(
    fontSize: 11,
    weight: FontWeight.w500,
    letterSpacing: 0.44, // 0.04em
    color: WBColors.fgSecondary,
  );

  // Button text — 16px Medium
  static TextStyle button = _albert(
    fontSize: 16,
    weight: FontWeight.w500,
    height: 1,
    color: Colors.white,
  );
}
