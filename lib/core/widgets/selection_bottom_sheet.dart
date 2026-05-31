import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/widgets/info_bottom_sheet.dart';

/// Simple reusable string picker shown as a modal bottom sheet.
class SelectionBottomSheet {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
  }) {
    final colors = context.appColors;
    return InfoBottomSheet.show<String>(
      context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (o) => ListTile(
                title: Text(
                  o,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textPrimary,
                  ),
                ),
                trailing: o == selected
                    ? Icon(Icons.check, color: colors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(o),
              ),
            )
            .toList(),
      ),
    );
  }
}
