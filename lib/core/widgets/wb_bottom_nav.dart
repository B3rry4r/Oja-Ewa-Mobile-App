import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';

/// One tab in [WBBottomNav]. `id` is the route the shell uses to switch and
/// to mark this slot active.
class WBNavItem {
  const WBNavItem({
    required this.id,
    required this.icon,
    required this.label,
  });
  final String id;
  final WBIconName icon;
  final String label;
}

/// Floating dark-pill bottom navigation. The active tab inflates into a white
/// capsule with a small inner black icon disc and a label. Active swap is
/// fully animated, the capsule expands smoothly into place rather than
/// popping.
///
/// Used by every role's shell (customer, vendor, agent, rider). Each shell
/// passes its own [items] and chooses [activeId] by matching the current
/// location.
class WBBottomNav extends StatelessWidget {
  const WBBottomNav({
    super.key,
    required this.items,
    required this.activeId,
    required this.onChanged,
  });

  final List<WBNavItem> items;
  final String activeId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
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
            for (final item in items)
              _NavSlot(
                item: item,
                active: item.id == activeId,
                onTap: () => onChanged(item.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final WBNavItem item;
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
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12),
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
                item.icon,
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
                    item.label,
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
