// notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/features/notifications/domain/notification_preferences.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildNotificationsList(context, ref),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.03,
                        child: Image.asset(
                          AppImages.logoOutline,
                          width: 234,
                          height: 347,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, WidgetRef ref) {
    // Use optimistic provider for immediate UI updates
    final prefs = ref.watch(optimisticPreferencesProvider);
    final isLoading =
        ref.watch(notificationPreferencesProvider).isLoading && prefs == null;
    final hasError =
        ref.watch(notificationPreferencesProvider).hasError && prefs == null;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFFDAF40)),
          ),
        ),
      );
    }

    if (hasError) {
      return Center(
        child: ElevatedButton(
          onPressed: () => ref.invalidate(notificationPreferencesProvider),
          child: const Text('Retry'),
        ),
      );
    }

    if (prefs == null) {
      return const Center(child: Text('Not logged in'));
    }

    final p = prefs;
    final items = <_PrefItem>[
      _PrefItem(
        title: 'Allow Push Notifications',
        value: p.allowPushNotifications,
        updater: (v) => p.copyWith(allowPushNotifications: v),
      ),
      _PrefItem(
        title: 'New Products',
        value: p.newProducts,
        updater: (v) => p.copyWith(newProducts: v),
      ),
      _PrefItem(
        title: 'Discount and Sales',
        value: p.discountAndSales,
        updater: (v) => p.copyWith(discountAndSales: v),
      ),
      _PrefItem(
        title: 'New Blog Posts',
        value: p.newBlogPosts,
        updater: (v) => p.copyWith(newBlogPosts: v),
      ),
      _PrefItem(
        title: 'New Orders',
        value: p.newOrders,
        updater: (v) => p.copyWith(newOrders: v),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          for (final item in items)
            _buildPrefRow(context: context, ref: ref, item: item),
        ],
      ),
    );
  }

  Widget _buildPrefRow({
    required BuildContext context,
    required WidgetRef ref,
    required _PrefItem item,
  }) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                color: Color(0xFF1E2021),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final updated = item.updater(!item.value);
              ref
                  .read(notificationsActionsProvider.notifier)
                  .updatePreferences(updated)
                  .catchError((e) {
                    if (!context.mounted) return;
                    AppSnackbars.showError(context, UiErrorMessage.from(e));
                  });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: item.value
                    ? const Color(0xFFA15E22)
                    : const Color(0xFFD9CFC5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: item.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.value
                          ? const Color(0xFFFDAF40)
                          : const Color(0xFFFFF8F1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefItem {
  _PrefItem({required this.title, required this.value, required this.updater});

  final String title;
  final bool value;
  final NotificationPreferences Function(bool) updater;
}
