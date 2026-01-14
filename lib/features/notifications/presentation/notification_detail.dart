import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/notifications/domain/app_notification.dart';

/// Screen to display a single notification's full content
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              iconColor: Colors.white,
              showActions: false,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.title.isNotEmpty 
                            ? notification.title 
                            : 'Notification',
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF241508),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Date
                      if (notification.createdAt != null)
                        Text(
                          _formatDate(notification.createdAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF777F84),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Body
                      Text(
                        notification.body,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E2021),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    final month = months[dt.month - 1];
    return '$month ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
