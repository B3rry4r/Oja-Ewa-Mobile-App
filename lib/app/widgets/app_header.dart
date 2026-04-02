import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';

/// Standard top header used across the app.
///
/// - Tab root screens: [showBack] should be false.
/// - Pushed screens: [showBack] should be true.
///
class AppHeader extends ConsumerWidget {
  const AppHeader({
    super.key,
    this.iconColor,
    this.showBack,
    this.showActions = true,
    this.onBack,
    this.title,
    this.backgroundColor,
    this.height = 44,
    this.topPadding = 8,
    this.horizontalPadding = 16,
    this.gap = 8,
  });

  final bool? showBack;
  final bool showActions;
  final VoidCallback? onBack;
  final Color? iconColor;
  final Widget? title;
  final Color? backgroundColor;

  final double height;
  final double topPadding;
  final double horizontalPadding;
  final double gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final resolvedIconColor = iconColor ?? colors.textPrimary;
    final shouldShowBack = showBack ?? Navigator.of(context).canPop();
    // Only fetch unread count if user is authenticated
    final accessToken = ref.watch(accessTokenProvider);
    final isAuthenticated = accessToken != null && accessToken.isNotEmpty;

    // Watch unread count for badge (only if authenticated)
    final unreadCount = isAuthenticated
        ? ref
              .watch(unreadCountProvider)
              .maybeWhen(data: (count) => count, orElse: () => 0)
        : 0;

    final left = shouldShowBack
        ? HeaderIconButton(
            asset: AppIcons.back,
            iconColor: resolvedIconColor,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          )
        : null;

    final right = showActions
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  HeaderIconButton(
                    asset: AppIcons.notification,
                    iconColor: resolvedIconColor,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: TextStyle(
                            color: colors.onAccent,
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
                iconColor: resolvedIconColor,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
              ),
            ],
          )
        : null;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        0,
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (left != null) left,
            if (left != null && title != null) const SizedBox(width: 12),
            if (title != null)
              Expanded(
                child: Align(
                  alignment: shouldShowBack
                      ? Alignment.centerLeft
                      : Alignment.center,
                  child: title!,
                ),
              )
            else
              const Spacer(),
            if (right != null) right,
          ],
        ),
      ),
    );
  }
}
