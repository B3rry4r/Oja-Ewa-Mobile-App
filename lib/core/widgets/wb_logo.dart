import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// WAWUBeauty brand "W" mark — the full-colour artwork from the brand kit,
/// rendered as-is (no tint). [color] is kept for API compatibility but is
/// no longer applied now that real artwork is supplied.
class WBWMark extends StatelessWidget {
  const WBWMark({super.key, this.size = 72, this.color = WBColors.fgHeader});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand_icons/W.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Wordmark variant — the full WAWUBeauty lock-up. Text placeholder until the
/// brand wordmark SVG is supplied.
class WBWordmark extends StatelessWidget {
  const WBWordmark({super.key, this.height = 32, this.color = WBColors.fgHeader});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'WAWUBeauty',
      style: WBTypography.page.copyWith(
        color: color,
        fontSize: height * 0.75,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1,
      ),
    );
  }
}
