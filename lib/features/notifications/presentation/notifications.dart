// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';

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
                      id: n.id,
                      title: (n.title.isEmpty ? n.body : n.title),
                      body: n.body,
                      timeAgo: n.createdAt?.toIso8601String().split('T').first ?? '',
                      isUnread: !n.isRead,
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
    required int id,
    required String title,
    required String body,
    required String timeAgo,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar/Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFA6A6A6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body.isEmpty ? title : body,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E2021),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF777F84),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action button (ellipsis)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isUnread ? Colors.orange.withOpacity(0.1) : Colors.transparent,
            ),
            child: IconButton(
              onPressed: () {
                ref.read(notificationsActionsProvider.notifier).markAsRead(id).catchError((e) {
                  if (!context.mounted) return;
                  AppSnackbars.showError(context, UiErrorMessage.from(e));
                });
              },
              icon: Icon(
                Icons.more_horiz,
                color: isUnread ? Colors.orange : Colors.grey,
                size: 24,
              ),
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }
}