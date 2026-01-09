// notifications_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

            // Notifications content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    // Notifications title
                    const Padding(
                      padding: EdgeInsets.only(top: 42),
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Campton',
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),

                    // Notifications list
                    _buildNotificationsList(),

                    // Decorative background image
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.03,
                        child: Image.asset(
                          'assets/images/notifications_decoration.png',
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

  Widget _buildNotificationsList() {
    final List<NotificationItem> notifications = [
      NotificationItem(title: 'Allow Push Notifications', isEnabled: false),
      NotificationItem(title: 'New Products', isEnabled: false),
      NotificationItem(title: 'Discount and Sales', isEnabled: false),
      NotificationItem(title: 'New Blog Posts', isEnabled: false),
      NotificationItem(title: 'New Orders', isEnabled: false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          for (var notification in notifications)
            _buildNotificationItem(notification),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 54,
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Notification title with padding
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

              // Toggle switch
              GestureDetector(
                onTap: () {
                  setState(() {
                    item.isEnabled = !item.isEnabled;
                  });
                },
                child: Container(
                  width: 62,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E9E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: item.isEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFBFB),
                          borderRadius: BorderRadius.circular(15.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
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
      },
    );
  }
}

class NotificationItem {
  String title;
  bool isEnabled;

  NotificationItem({required this.title, required this.isEnabled});
}
