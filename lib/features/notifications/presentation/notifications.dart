// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/features/notifications/domain/app_notification.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/features/notifications/presentation/notification_detail.dart';
import 'package:ojaewa/features/business_details/presentation/screens/business_details_screen.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF603814), // Main background color
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              iconColor: Colors.white,
              showActions: false,
            ),
            // Main content card
            Expanded(
              child: _buildNotificationContent(context, ref, notifications),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
    );
  }

  Widget _buildNotificationContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue notifications,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Padding(
              padding: EdgeInsets.only(left: 18, top: 16, bottom: 20),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 33,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),
            // Notification list
            notifications.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFDAF40)),
                  ),
                ),
              ),
              error: (e, st) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  AppSnackbars.showError(context, UiErrorMessage.from(e));
                });
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Failed to load notifications.')),
                );
              },

              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'You have no notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF241508),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We\'ll let you know when something important happens.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF777F84),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final n in items) _buildNotificationItem(
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
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required WidgetRef ref,
    required AppNotification notification,
  }) {
    final isUnread = !notification.isRead;
    final title = notification.title.isNotEmpty ? notification.title : 'Notification';
    final body = notification.body;
    final timeAgo = notification.createdAt != null 
        ? _formatTimeAgo(notification.createdAt!) 
        : '';

    return GestureDetector(
      onTap: () {
        // Mark as read optimistically when opening
        if (isUnread) {
          ref.read(notificationsActionsProvider.notifier).markAsRead(notification.id).catchError((e) {
            if (!context.mounted) return;
            AppSnackbars.showError(context, UiErrorMessage.from(e));
          });
        }

        final deepLink = notification.deepLink;
        if (deepLink != null && deepLink.isNotEmpty) {
          _handleDeepLinkNavigation(context, deepLink);
          return;
        }

        // Fallback: open detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NotificationDetailScreen(notification: notification),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFDAF40).withAlpha(20) : Colors.transparent,
          border: Border.all(
            color: isUnread ? const Color(0xFFFDAF40) : const Color(0xFFCCCCCC),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFDAF40),
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
                      fontFamily: 'Campton',
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF241508),
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Body preview
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: isUnread ? const Color(0xFF1E2021) : const Color(0xFF777F84),
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF777F84),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow indicator
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFF777F84),
                size: 20,
              ),
            ),
          ],
        ),
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
            MaterialPageRoute(builder: (_) => BusinessDetailsScreen(businessId: id)),
          );
          return;
        }
      }

      if (segments.length >= 2 && segments[0] == 'products') {
        final id = int.tryParse(segments[1]);
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)),
          );
          return;
        }
      }

      if (segments.isNotEmpty && segments[0] == 'orders') {
        // We don't yet support order-id specific screen; send to orders list.
        Navigator.of(context).pushNamed(AppRoutes.orders);
        return;
      }

      if (segments.length >= 2 && segments[0] == 'seller' && segments[1] == 'profile') {
        Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard);
        return;
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