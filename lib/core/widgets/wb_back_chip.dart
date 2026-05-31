import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';

/// Circular 44px back chip with soft card shadow, used in screen headers.
class WBBackChip extends StatelessWidget {
  const WBBackChip({super.key, this.onPressed, this.icon = WBIconName.chevronLeft});

  final VoidCallback? onPressed;
  final WBIconName icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: WBColors.bgPrimary,
          shape: BoxShape.circle,
          boxShadow: WBShadows.card,
        ),
        alignment: Alignment.center,
        child: WBIcon(icon, size: 20, color: WBColors.fgHeader),
      ),
    );
  }
}

/// Inline header row: back chip · title · optional trailing widget.
class WBScreenHeader extends StatelessWidget {
  const WBScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          WBBackChip(onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: WBTypography.cardTitle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: trailing == null ? null : Center(child: trailing),
          ),
        ],
      ),
    );
  }
}
