// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/draft_utils.dart';
import 'package:ojaewa/features/notifications/domain/app_notification.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/features/notifications/presentation/notification_detail.dart';
import 'package:ojaewa/features/business_details/presentation/screens/business_details_screen.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';
import 'package:ojaewa/features/your_shop/subfeatures/orders/shop_order_details.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsListProvider);

    return AppPageScaffold(
      title: 'Notifications',
      showActions: false,
      child: _buildNotificationContent(context, ref, notifications),
    );
  }

  Widget _buildNotificationContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue notifications,
  ) {
    final colors = context.appColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification list
                  notifications.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, st) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        AppSnackbars.showError(context, UiErrorMessage.from(e));
                      });
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Failed to load notifications.',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                      );
                    },

                    data: (items) {
                      if (items.isEmpty) {
                        return const WBEmptyState(
                          illustration: WBEmptyIllustration.noOrders,
                          label: 'You have no notifications',
                          sub:
                              'We\'ll let you know when something important happens.',
                        );
                      }

                      return Column(
                        children: [
                          for (final n in items)
                            _buildNotificationItem(
                              context: context,
                              ref: ref,
                              notification: n,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required WidgetRef ref,
    required AppNotification notification,
  }) {
    final colors = context.appColors;
    final isUnread = !notification.isRead;
    final title = notification.title.isNotEmpty
        ? notification.title
        : 'Notification';
    final body = notification.body;
    final timeAgo = notification.createdAt != null
        ? _formatTimeAgo(notification.createdAt!)
        : '';

    return GestureDetector(
      onTap: () {
        // Mark as read optimistically when opening
        if (isUnread) {
          ref
              .read(notificationsActionsProvider.notifier)
              .markAsRead(notification.id)
              .catchError((e) {
                if (!context.mounted) return;
                AppSnackbars.showError(context, UiErrorMessage.from(e));
              });
        }

        _handleNotificationTap(context, ref, notification);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? colors.accent.withValues(alpha: 0.08)
              : colors.surface,
          border: Border.all(
            color: isUnread ? colors.accent : colors.border,
            width: isUnread ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 22), // Spacer to align content
            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Body preview
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isUnread
                            ? colors.textPrimary
                            : colors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Time
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.chevron_right,
                color: colors.textTertiary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    final payloadStatus = notification.payloadStatus;

    if (payloadStatus == 'rejected' &&
        notification.deepLink == '/seller/profile') {
      final status = await ref.read(mySellerStatusProvider.future);
      if (!context.mounted) return;
      if (status != null) {
        Navigator.of(context).pushNamed(
          AppRoutes.sellerRegistration,
          arguments: sellerDraftFromStatus(status).toJson(),
        );
        return;
      }
    }

    if ((payloadStatus == 'deactivated' || payloadStatus == 'rejected') &&
        notification.businessId != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.editBusiness,
        arguments: {'businessId': notification.businessId},
      );
      return;
    }

    final deepLink = notification.deepLink;
    if (deepLink != null && deepLink.isNotEmpty) {
      _handleDeepLinkNavigation(context, deepLink);
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(notification: notification),
      ),
    );
  }

  void _handleDeepLinkNavigation(BuildContext context, String deepLink) {
    // Expected formats:
    // /business/{id}
    // /products/{id}
    // /orders/{id}
    // /seller/profile
    try {
      final uri = Uri.parse(deepLink);
      final segments = uri.pathSegments;
      if (segments.isEmpty) {
        return;
      }

      if (segments.length >= 2 && segments[0] == 'business') {
        final id = int.tryParse(segments[1]);
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BusinessDetailsScreen(businessId: id),
            ),
          );
          return;
        }
      }

      if (segments.length >= 2 && segments[0] == 'products') {
        final id = int.tryParse(segments[1]);
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: id),
            ),
          );
          return;
        }
      }

      if (segments.isNotEmpty && segments[0] == 'orders') {
        // We don't yet support order-id specific screen; send to orders list.
        Navigator.of(context).pushNamed(AppRoutes.orders);
        return;
      }

      if (segments.length >= 2 && segments[0] == 'seller') {
        if (segments[1] == 'profile') {
          Navigator.of(context).pushNamed(AppRoutes.sellerApprovalStatus);
          return;
        }
        // Handle /seller/orders/{id}
        if (segments.length >= 3 && segments[1] == 'orders') {
          final orderId = int.tryParse(segments[2]);
          if (orderId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShopOrderDetailsScreen(orderId: orderId),
              ),
            );
            return;
          }
        }
      }

      // Unknown deep link → do nothing
    } catch (_) {
      // Ignore invalid deep links
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
