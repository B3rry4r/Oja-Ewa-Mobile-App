// notifications_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../app/widgets/app_header.dart';
import '../../../../../core/resources/app_assets.dart';
import '../../../../../core/ui/snackbars.dart';
import '../../../../../core/notifications/fcm_service.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPushNotificationState();
  }

  bool _pushEnabled = false;

  Future<void> _loadPushNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('push_notifications_enabled') ?? false;
    setState(() {
      _pushEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _savePushNotificationState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications_enabled', enabled);
  }

  Future<void> _handlePushToggle(bool newValue) async {
    try {
      if (newValue) {
        // Enable push notifications - register with FCM
        final fcmService = ref.read(fcmServiceProvider);
        await fcmService.requestPermissionAndInitialize();
        if (mounted) AppSnackbars.showSuccess(context, 'Push notifications enabled');
      } else {
        // Disable push notifications - delete FCM token
        final fcmService = ref.read(fcmServiceProvider);
        await fcmService.deleteToken();
        if (mounted) AppSnackbars.showSuccess(context, 'Push notifications disabled');
      }
      
      // Save state and update UI
      await _savePushNotificationState(newValue);
      setState(() => _pushEnabled = newValue);
    } catch (e) {
      if (mounted) AppSnackbars.showError(context, 'Failed to update notification settings');
    }
  }

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildNotificationsList(),
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

  Widget _buildNotificationsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildPushToggle(),
        ],
      ),
    );
  }

  Widget _buildPushToggle() {
    final enabled = _pushEnabled;
    
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: const Text(
              'Allow Push Notifications',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                color: Color(0xFF1E2021),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _handlePushToggle(!enabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFFA15E22)
                    : const Color(0xFFD9CFC5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: enabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: enabled
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
