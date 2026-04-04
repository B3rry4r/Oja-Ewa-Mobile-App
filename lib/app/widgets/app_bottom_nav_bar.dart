import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

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
    final colors = context.appColors;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset > 0 ? 8 : 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: AppBottomNavBar.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  iconAsset: AppIcons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  iconAsset: AppIcons.search,
                  label: 'Search',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  iconAsset: AppIcons.wishlist,
                  label: 'Wishlist',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  iconAsset: AppIcons.blog,
                  label: 'Blog',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  iconAsset: AppIcons.account,
                  label: 'Account',
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconAsset,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isActive ? colors.accent : colors.textTertiary;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
