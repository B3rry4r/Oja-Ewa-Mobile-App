import 'package:flutter/material.dart';

import 'package:ojaewa/core/widgets/info_bottom_sheet.dart';

/// Simple reusable string picker shown as a modal bottom sheet.
class SelectionBottomSheet {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
  }) {
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
                  style: const TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 16,
                    color: Color(0xFF1E2021),
                  ),
                ),
                trailing: o == selected
                    ? const Icon(Icons.check, color: Color(0xFF603814))
                    : null,
                onTap: () => Navigator.of(context).pop(o),
              ),
            )
            .toList(),
      ),
    );
  }
}
