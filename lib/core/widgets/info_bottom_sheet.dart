import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

/// Reusable modal bottom sheet for displaying read-only text content.
///
/// Matches the product description bottom sheet styling (cream background,
/// rounded top corners, drag handle, 0.7 dark barrier).
class InfoBottomSheet extends StatelessWidget {
  const InfoBottomSheet({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => InfoBottomSheet(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Campton',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      HeaderIconButton(
                        asset: AppIcons.back,
                        iconColor: colors.textPrimary,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                Divider(color: colors.border, thickness: 0.5),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
