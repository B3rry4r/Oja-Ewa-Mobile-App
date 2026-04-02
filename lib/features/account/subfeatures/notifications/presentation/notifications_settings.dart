// notifications_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../../../../app/theme/app_theme_colors.dart';
import '../../../../../app/widgets/app_page_scaffold.dart';
import '../../../../../core/resources/app_assets.dart';
import '../../../../../core/ui/snackbars.dart';
import '../../../../../core/notifications/fcm_service.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
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
    final permissionGranted =
        prefs.getBool('push_notifications_permission_granted') ?? false;
    final registeredToken =
        prefs.getBool('push_notifications_token_registered') ?? false;
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
    await prefs.setBool(
      'push_notifications_permission_granted',
      permissionGranted,
    );
    await prefs.setBool('push_notifications_token_registered', tokenRegistered);
  }

  Future<void> _handlePushToggle(bool newValue) async {
    try {
      debugPrint('Push toggle requested: $newValue');
      if (newValue) {
        final fcmService = ref.read(fcmServiceProvider);
        bool registeredToken;
        if (kIsWeb) {
          await fcmService.sendWebTestRegistration();
          registeredToken = true;
        } else if (Platform.isIOS) {
          registeredToken = await fcmService.requestPermissionAndInitialize();
        } else {
          registeredToken = await fcmService.initializeWithoutPrompt();
        }
        final permissionGranted = await fcmService.isPermissionGranted();
        if (!registeredToken) {
          debugPrint(
            'Notifications enable failed: permission=$permissionGranted token=$registeredToken',
          );
          if (mounted) {
            if (!permissionGranted) {
              AppSnackbars.showError(
                context,
                'Please enable notifications in your device Settings, then try again.',
              );
            } else {
              AppSnackbars.showError(
                context,
                'Could not register for push notifications. Please try again.',
              );
            }
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
        if (mounted) {
          AppSnackbars.showSuccess(context, 'Push notifications enabled');
        }
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
        if (mounted) {
          AppSnackbars.showSuccess(context, 'Push notifications disabled');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(
          context,
          'Failed to update notification settings',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'Notifications',
      scrollable: true,
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
    );
  }

  Widget _buildNotificationsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [const SizedBox(height: 16), _buildPushToggle()]),
    );
  }

  Widget _buildPushToggle() {
    final colors = context.appColors;
    final enabled = _pushEnabled && _permissionGranted && _hasRegisteredToken;

    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Allow Push Notifications',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                color: colors.textPrimary,
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
                color: enabled ? colors.accent : colors.borderStrong,
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
                      color: enabled ? colors.surface : colors.surfaceElevated,
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
