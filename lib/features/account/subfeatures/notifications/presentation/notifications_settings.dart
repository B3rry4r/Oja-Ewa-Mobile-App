// notifications_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

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
  bool _permissionGranted = false;
  bool _hasRegisteredToken = false;

  Future<void> _loadPushNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('push_notifications_enabled') ?? false;
    final permissionGranted = prefs.getBool('push_notifications_permission_granted') ?? false;
    final registeredToken = prefs.getBool('push_notifications_token_registered') ?? false;
    setState(() {
      _pushEnabled = enabled;
      _permissionGranted = permissionGranted;
      _hasRegisteredToken = registeredToken;
      _isLoading = false;
    });
  }

  Future<void> _savePushNotificationState({
    required bool enabled,
    required bool permissionGranted,
    required bool tokenRegistered,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications_enabled', enabled);
    await prefs.setBool('push_notifications_permission_granted', permissionGranted);
    await prefs.setBool('push_notifications_token_registered', tokenRegistered);
  }

  Future<void> _handlePushToggle(bool newValue) async {
    try {
      debugPrint('Push toggle requested: $newValue');
      if (newValue) {
        final fcmService = ref.read(fcmServiceProvider);
        final bool registeredToken = Platform.isIOS
            ? await fcmService.requestPermissionAndInitialize()
            : await fcmService.initializeWithoutPrompt();
        final permissionGranted = await fcmService.isPermissionGranted();
        if (kIsWeb) {
          await fcmService.sendWebTestRegistration();
        }
        if (!permissionGranted || !registeredToken) {
          debugPrint('Notifications enable failed: permission=$permissionGranted token=$registeredToken');
          if (mounted) {
            AppSnackbars.showError(
              context,
              'Push notifications could not be enabled. Please allow permissions.',
            );
          }
          await _savePushNotificationState(
            enabled: false,
            permissionGranted: permissionGranted,
            tokenRegistered: registeredToken,
          );
          setState(() {
            _pushEnabled = false;
            _permissionGranted = permissionGranted;
            _hasRegisteredToken = registeredToken;
          });
          return;
        }
        if (mounted) AppSnackbars.showSuccess(context, 'Push notifications enabled');
        await _savePushNotificationState(
          enabled: true,
          permissionGranted: permissionGranted,
          tokenRegistered: registeredToken,
        );
        setState(() {
          _pushEnabled = true;
          _permissionGranted = permissionGranted;
          _hasRegisteredToken = registeredToken;
        });
      } else {
        final fcmService = ref.read(fcmServiceProvider);
        await fcmService.deleteToken();
        await _savePushNotificationState(
          enabled: false,
          permissionGranted: false,
          tokenRegistered: false,
        );
        setState(() {
          _pushEnabled = false;
          _permissionGranted = false;
          _hasRegisteredToken = false;
        });
        if (mounted) AppSnackbars.showSuccess(context, 'Push notifications disabled');
      }
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
    final enabled = _pushEnabled && _permissionGranted && _hasRegisteredToken;

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
