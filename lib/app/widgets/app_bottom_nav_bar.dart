import 'package:flutter/material.dart';

import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_icon.dart';

/// Floating dark-pill bottom navigation, matching the WAWUBasket design
/// system. The active tab inflates into a white capsule with a small inner
/// dark icon disc and a label; the swap is fully animated.
///
/// Keeps the original [currentIndex]/[onTap] contract so [AppShell] is
/// unchanged. Uses the WB line-icon set.
class AppBottomNavBar extends StatelessWidget {
  static const double height = 70;
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = <({WBIconName icon, String label})>[
      (icon: WBIconName.home, label: l.navHome),
      (icon: WBIconName.search, label: l.navSearch),
      (icon: WBIconName.services, label: l.navServices),
      (icon: WBIconName.heart, label: l.navWishlist),
      (icon: WBIconName.user, label: l.navAccount),
    ];
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: WBColors.surfaceDark,
          borderRadius: BorderRadius.circular(WBRadius.pill),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              offset: Offset(0, 12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavSlot(
                icon: items[i].icon,
                label: items[i].label,
                active: i == currentIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final WBIconName icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: active ? 14 : 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: WBMotion.base,
              curve: WBMotion.easeSoft,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: active ? WBColors.fgHeader : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WBIcon(
                icon,
                size: active ? 15 : 20,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.85),
              ),
            ),
            ClipRect(
              child: AnimatedAlign(
                duration: WBMotion.base,
                curve: WBMotion.easeSoft,
                alignment: Alignment.centerLeft,
                widthFactor: active ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgHeader,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
