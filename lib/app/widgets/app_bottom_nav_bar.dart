import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';

/// Floating dark-pill bottom navigation, matching the WAWUBasket design
/// system. The active tab inflates into a white capsule with a small inner
/// dark icon disc and a label; the swap is fully animated.
///
/// Keeps the original [currentIndex]/[onTap] contract so [AppShell] is
/// unchanged. Uses the app's existing SVG tab icons (Blog has no WB icon
/// equivalent) rendered in the WB monochrome style.
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
    final items = <({String asset, String label})>[
      (asset: AppIcons.home, label: l.navHome),
      (asset: AppIcons.search, label: l.navSearch),
      (asset: AppIcons.wishlist, label: l.navWishlist),
      (asset: AppIcons.blog, label: l.navBlog),
      (asset: AppIcons.account, label: l.navAccount),
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
                asset: items[i].asset,
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
    required this.asset,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String asset;
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
              child: SvgPicture.asset(
                asset,
                width: active ? 15 : 20,
                height: active ? 15 : 20,
                colorFilter: ColorFilter.mode(
                  active ? Colors.white : Colors.white.withValues(alpha: 0.85),
                  BlendMode.srcIn,
                ),
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
