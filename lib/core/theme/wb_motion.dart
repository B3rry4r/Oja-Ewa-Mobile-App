import 'package:flutter/animation.dart';

/// WAWUBasket motion tokens — soft, subtle, premium.
abstract final class WBMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);

  /// `cubic-bezier(0.32, 0.72, 0, 1)` — same easing curve used in CSS tokens.
  static const Cubic easeSoft = Cubic(0.32, 0.72, 0, 1);
}
