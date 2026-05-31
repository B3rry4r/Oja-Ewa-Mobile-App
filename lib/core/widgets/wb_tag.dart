import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';

/// Pill-shaped tag/chip. Active = dark surface + white text.
class WBTag extends StatelessWidget {
  const WBTag({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.leading,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WBMotion.base,
        curve: WBMotion.easeSoft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? WBColors.surfaceDark : WBColors.surfaceTag,
          borderRadius: BorderRadius.circular(WBRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: WBTypography.caption.copyWith(
                color: active ? Colors.white : WBColors.fgHeader,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum WBStatusKind { success, error, warning, info }

class WBStatusPill extends StatelessWidget {
  const WBStatusPill({super.key, required this.label, required this.kind});

  final String label;
  final WBStatusKind kind;

  ({Color bg, Color fg}) get _palette {
    switch (kind) {
      case WBStatusKind.success:
        return (bg: const Color(0x1F22C55E), fg: WBColors.statusSuccessFg);
      case WBStatusKind.error:
        return (bg: const Color(0x1FEF4444), fg: WBColors.statusErrorFg);
      case WBStatusKind.warning:
        return (bg: const Color(0x24F59E0B), fg: WBColors.statusWarningFg);
      case WBStatusKind.info:
        return (bg: const Color(0x1F3B82F6), fg: WBColors.statusInfoFg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: p.fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: WBTypography.caption.copyWith(
              color: p.fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
