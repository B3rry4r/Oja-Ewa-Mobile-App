import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';

/// Standard top header used across the app.
///
/// - Tab root screens: [showBack] should be false.
/// - Pushed screens: [showBack] should be true.
///
/// Keeps existing layout conventions: 40x40 square buttons, 104px bar height,
/// and 32px top padding.
class AppHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Only fetch unread count if user is authenticated
    final accessToken = ref.watch(accessTokenProvider);
    final isAuthenticated = accessToken != null && accessToken.isNotEmpty;
    
    // Watch unread count for badge (only if authenticated)
    final unreadCount = isAuthenticated 
        ? ref.watch(unreadCountProvider).maybeWhen(
            data: (count) => count,
            orElse: () => 0,
          )
        : 0;

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
                // Notification icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    HeaderIconButton(
                      asset: AppIcons.notification,
                      iconColor: iconColor,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.notifications,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDAF40),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Campton',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: gap),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  iconColor: iconColor,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.cart,
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
