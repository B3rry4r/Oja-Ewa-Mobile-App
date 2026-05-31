import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';

/// 44×44 floating round button with the system's card shadow. Used for back
/// chips, header notifications, etc.
class WBCircleIconButton extends StatelessWidget {
  const WBCircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.background = WBColors.bgPrimary,
    this.iconColor = WBColors.fgHeader,
    this.badge = false,
    this.shadow,
  });

  final WBIconName icon;
  final VoidCallback? onPressed;
  final double size;
  final Color background;
  final Color iconColor;
  final bool badge;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                boxShadow: shadow ?? WBShadows.card,
              ),
              alignment: Alignment.center,
              child: WBIcon(icon, size: 20, color: iconColor),
            ),
            if (badge)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: WBColors.statusError,
                    shape: BoxShape.circle,
                    border: Border.all(color: WBColors.bgPrimary, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
