import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';

/// Pill quantity stepper, soft tray with a white minus and a dark plus.
class WBQtyStepper extends StatelessWidget {
  const WBQtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: WBColors.bgSoft,
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(
            background: WBColors.bgPrimary,
            color: WBColors.fgHeader,
            icon: WBIconName.minus,
            onTap: () => onChanged(value > min ? value - 1 : min),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 18,
            child: Center(
              child: Text(
                '$value',
                style: WBTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: WBColors.fgHeader,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _btn(
            background: WBColors.surfaceDark,
            color: Colors.white,
            icon: WBIconName.plus,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _btn({
    required Color background,
    required Color color,
    required WBIconName icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: WBIcon(icon, size: 14, color: color, strokeWidth: 2),
      ),
    );
  }
}
