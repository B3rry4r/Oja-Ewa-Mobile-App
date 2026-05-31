import 'package:flutter/material.dart';

/// Soft, single-layer shadows — the design system avoids stacked/dark depth.
abstract final class WBShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // rgba(0,0,0,0.04)
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x0F000000), // rgba(0,0,0,0.06)
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> nav = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
