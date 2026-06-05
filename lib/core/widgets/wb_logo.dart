import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/app_assets.dart';
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

/// WAWUBeauty brand logo — the "WB" cart monogram lock-up from the brand kit.
///
/// Rendered from a single-colour SVG and tinted via [color] so it adapts to
/// both light and dark surfaces. Sized by [height]; width follows the
/// artwork's natural aspect ratio.
class WBWordmark extends StatelessWidget {
  const WBWordmark({super.key, this.height = 32, this.color});

  final double height;

  /// When null the logo renders in its native brand colour (black). Pass a
  /// colour only to tint it for a specific surface — e.g. white on a dark hero.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppImages.wbLogo,
      height: height,
      fit: BoxFit.contain,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: 'WAWUBeauty',
    );
  }
}
