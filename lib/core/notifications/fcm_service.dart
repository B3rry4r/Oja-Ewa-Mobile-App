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

  Future<bool> isPermissionGranted() async {
    if (_fcmToken != null) return true;
    if (kIsWeb) return false;
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Initialize FCM (call this after user is authenticated)
  Future<bool> requestPermissionAndInitialize() async {
    if (_initialized && _fcmToken != null) {
      debugPrint('FCM already initialized with token');
      return true;
    }
    // If not initialized but permissions already granted, skip the prompt
    if (!_initialized) {
      final existing = await _messaging.getNotificationSettings();
      if (existing.authorizationStatus == AuthorizationStatus.authorized ||
          existing.authorizationStatus == AuthorizationStatus.provisional) {
        // Already granted - just get the token without prompting
        _fcmToken ??= await _messaging.getToken();
        if (_fcmToken != null) {
          _initialized = true;
          await _sendTokenToBackend(_fcmToken!);
          _messaging.onTokenRefresh.listen((t) { _fcmToken = t; _sendTokenToBackend(t); });
          _setupMessageHandlers();
          FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
          return true;
        }
      }
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
          final registered = await _sendTokenToBackend(_fcmToken!);
          if (!registered) {
            debugPrint('FCM token registration failed');
          }
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
        return _fcmToken != null;
      } else {
        debugPrint('FCM Permission denied');
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
    return false;
  }

  /// Attempt to register token without prompting (Android auto-grants).
  Future<bool> initializeWithoutPrompt() async {
    if (_initialized) {
      return _fcmToken != null;
    }

    try {
      // On Android, request permission (API 33+ needs explicit grant, lower auto-grants)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM Permission status: ${settings.authorizationStatus}');

      // On Android, even notDetermined means we can still get a token
      // Only skip if explicitly denied
      if (settings.authorizationStatus != AuthorizationStatus.denied) {
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          final registered = await _sendTokenToBackend(_fcmToken!);
          if (!registered) {
            debugPrint('FCM token registration failed');
          }
        }
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _sendTokenToBackend(newToken);
        });
        _setupMessageHandlers();
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        _initialized = true;
        return _fcmToken != null;
      }
    } catch (e) {
      debugPrint('FCM silent init error: $e');
    }
    return false;
  }

  /// Setup foreground and background message handlers
  void _setupMessageHandlers() {
    // Foreground messages - show as in-app notification banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // Show the notification as an in-app banner via the on-message callback
      _onMessageCallback?.call(message);
    });

    // When user taps notification (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.messageId}');
      debugPrint('Data: ${message.data}');
      _onNotificationTapCallback?.call(message.data);
    });

    // Check if app was opened from a terminated state via notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification: ${message.messageId}');
        debugPrint('Data: ${message.data}');
        _onNotificationTapCallback?.call(message.data);
      }
    });
  }

  void Function(RemoteMessage)? _onMessageCallback;
  void Function(Map<String, dynamic>)? _onNotificationTapCallback;

  void setOnMessageCallback(void Function(RemoteMessage) callback) {
    _onMessageCallback = callback;
  }

  void setOnNotificationTapCallback(void Function(Map<String, dynamic>) callback) {
    _onNotificationTapCallback = callback;
  }

  Future<void> sendWebTestRegistration() async {
    if (!kIsWeb) {
      return;
    }
    if (_notificationsApi == null) {
      debugPrint('NotificationsApi not available for web test registration');
      return;
    }
    try {
      await _notificationsApi.registerDeviceToken(
        token: 'web-test-token',
        deviceType: 'web',
      );
      debugPrint('Web test token registered');
    } catch (e) {
      debugPrint('Web test registration failed: $e');
    }
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
  Future<bool> _sendTokenToBackend(String token) async {
    if (_notificationsApi == null) {
      debugPrint('NotificationsApi not available, skipping token registration');
      return false;
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
      return true;
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
      return false;
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
