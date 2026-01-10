// notifications_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: _buildNotificationContent(),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
    );
  }

  Widget _buildNotificationContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
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
            _buildNotificationItem(
              timeAgo: '1 week ago',
              isUnread: true,
            ),
            _buildNotificationItem(
              timeAgo: '23 Feb, 2023',
              isUnread: false,
            ),
            // Add more notification items as needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
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
                const Text(
                  'Discount! Agbad in vogue new year sales is up. Order now and get 20% discount',
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
              onPressed: () {},
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