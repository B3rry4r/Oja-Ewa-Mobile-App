import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    this.borderColor = const Color(0xFFDEDEDE),
    this.iconColor = const Color(0xFF241508),
  });

  final String asset;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
