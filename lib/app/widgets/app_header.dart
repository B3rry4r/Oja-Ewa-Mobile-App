import 'package:flutter/material.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

/// Standard top header used across the app.
///
/// - Tab root screens: [showBack] should be false.
/// - Pushed screens: [showBack] should be true.
///
/// Keeps existing layout conventions: 40x40 square buttons, 104px bar height,
/// and 32px top padding.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.iconColor,
    this.showBack = true,
    this.showActions = true,
    this.onBack,
    this.title,
    this.backgroundColor = const Color(0xFF603814),
    this.height = 104,
    this.topPadding = 32,
    this.horizontalPadding = 16,
    this.gap = 8,
  });

  final bool showBack;
  final bool showActions;
  final VoidCallback? onBack;
  final Color iconColor;
  final Widget? title;
  final Color backgroundColor;

  final double height;
  final double topPadding;
  final double horizontalPadding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final left = Padding(
      padding: EdgeInsets.only(left: horizontalPadding),
      child: showBack
          ? HeaderIconButton(
              asset: AppIcons.back,
              iconColor: iconColor,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : const SizedBox(width: 40, height: 40),
    );

    final right = Padding(
      padding: EdgeInsets.only(right: horizontalPadding),
      child: showActions
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeaderIconButton(
                  asset: AppIcons.notification,
                  iconColor: iconColor,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.notifications,
                  ),
                ),
                SizedBox(width: gap),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  iconColor: iconColor,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.shoppingBag,
                  ),
                ),
              ],
            )
          : const SizedBox(width: 40, height: 40),
    );

    return Container(
      height: height,
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center title.
            if (title != null) Center(child: title),

            // Left + right controls.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [left, right],
            ),
          ],
        ),
      ),
    );
  }
}
