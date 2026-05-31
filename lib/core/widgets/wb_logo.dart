import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Brand mark placeholder. The real WAWUBeauty artwork is supplied after the
/// redesign; until then this renders a clean monochrome lettermark ("WB") so
/// no screen depends on a missing asset.
class WBWMark extends StatelessWidget {
  const WBWMark({super.key, this.size = 72, this.color = WBColors.fgHeader});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        'W',
        style: WBTypography.hero.copyWith(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
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
