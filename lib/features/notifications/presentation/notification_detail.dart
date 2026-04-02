import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/notifications/domain/app_notification.dart';

/// Screen to display a single notification's full content
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      showActions: false,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              notification.title.isNotEmpty
                  ? notification.title
                  : 'Notification',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Date
            if (notification.createdAt != null)
              Text(
                _formatDate(notification.createdAt!),
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),

            const SizedBox(height: 24),

            // Body
            Text(
              notification.body,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[dt.month - 1];
    return '$month ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
