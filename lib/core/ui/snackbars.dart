import 'package:flutter/material.dart';

import 'package:ojaewa/core/theme/wb_theme_exports.dart';

class AppSnackbars {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WBColors.statusError,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WBColors.statusSuccessFg,
      ),
    );
  }
}
