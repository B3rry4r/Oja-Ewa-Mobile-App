import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/data/notifications_api.dart';
import '../../features/notifications/data/notifications_repository_impl.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

/// Firebase Cloud Messaging Service
class FCMService {
  FCMService({NotificationsApi? notificationsApi}) : _notificationsApi = notificationsApi;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationsApi? _notificationsApi;
  String? _fcmToken;
  bool _initialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize FCM (call this after user is authenticated)
  Future<void> requestPermissionAndInitialize() async {
    if (_initialized) {
      debugPrint('FCM already initialized');
      return;
    }

    try {
      // Request permissions (iOS - Android auto-granted)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('FCM Token: $_fcmToken');

        // Send token to backend
        if (_fcmToken != null) {
          await _sendTokenToBackend(_fcmToken!);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          _sendTokenToBackend(newToken);
        });

        // Setup message handlers
        _setupMessageHandlers();

        // Register background handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        
        _initialized = true;
      } else {
        debugPrint('FCM Permission denied');
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// Attempt to register token without prompting (Android auto-grants).
  Future<void> initializeWithoutPrompt() async {
    if (_initialized) {
      return;
    }

    try {
      final settings = await _messaging.getNotificationSettings();
      final status = settings.authorizationStatus;
      if (status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional) {
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          await _sendTokenToBackend(_fcmToken!);
        }
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _sendTokenToBackend(newToken);
        });
        _setupMessageHandlers();
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        _initialized = true;
      }
    } catch (e) {
      debugPrint('FCM silent init error: $e');
    }
  }

  /// Setup foreground and background message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // TODO: Show local notification or update UI
    });

    // When user taps notification (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.messageId}');
      debugPrint('Data: ${message.data}');

      // TODO: Navigate to appropriate screen based on message.data
    });

    // Check if app was opened from a terminated state via notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification: ${message.messageId}');
        debugPrint('Data: ${message.data}');

        // TODO: Navigate to appropriate screen
      }
    });
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      // Delete from backend first
      if (_fcmToken != null && _notificationsApi != null) {
        await _notificationsApi.deleteDeviceToken(token: _fcmToken!);
      }
      
      // Then delete from Firebase
      await _messaging.deleteToken();
      _fcmToken = null;
      _initialized = false;
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Send token to backend
  Future<void> _sendTokenToBackend(String token) async {
    if (_notificationsApi == null) {
      debugPrint('NotificationsApi not available, skipping token registration');
      return;
    }

    try {
      String deviceType = 'mobile';
      if (Platform.isIOS) {
        deviceType = 'ios';
      } else if (Platform.isAndroid) {
        deviceType = 'android';
      }

      await _notificationsApi.registerDeviceToken(
        token: token,
        deviceType: deviceType,
      );
      debugPrint('FCM token registered with backend: $deviceType');
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
    }
  }
}

/// Provider for FCM Service (lazy - only creates when accessed)
final fcmServiceProvider = Provider<FCMService>((ref) {
  final notificationsApi = ref.watch(notificationsApiProvider);
  return FCMService(notificationsApi: notificationsApi);
});

/// Provider for FCM Token
final fcmTokenProvider = Provider<String?>((ref) {
  return ref.watch(fcmServiceProvider).fcmToken;
});
