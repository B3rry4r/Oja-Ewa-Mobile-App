import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';

class TribePickerSheet extends StatelessWidget {
  const TribePickerSheet({
    super.key,
    required this.options,
    required this.selected,
  });

  final List<String> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: Column(
        children: [
          // Tap outside area (overlay)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              border: Border(top: BorderSide(color: colors.border)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select tribe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...options.map((t) {
                  final isSelected = t == selected;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(t),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? colors.accent
                                : colors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            t,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
