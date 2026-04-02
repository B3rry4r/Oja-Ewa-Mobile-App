import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';

/// Square icon button used in top headers (matches the design).
///
/// Uses [GestureDetector] to avoid InkWell's circular splash.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.asset,
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.borderColor,
    this.iconColor,
    this.backgroundColor,
  });

  final String asset;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? borderColor;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final resolvedBorderColor = borderColor ?? colors.border;
    final resolvedIconColor = iconColor ?? colors.textPrimary;
    final resolvedBackgroundColor = backgroundColor ?? colors.iconBackground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          border: Border.all(color: resolvedBorderColor),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(resolvedIconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
