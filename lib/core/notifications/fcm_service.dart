import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/data/notifications_api.dart';
import '../../features/notifications/data/notifications_repository_impl.dart';
import '../logger/remote_logger.dart';

/// Top-level plugin instance for use in background handler
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Android notification channel for high-importance foreground notifications
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'ojaewa_high_importance_channel',
  'Ojaewa Notifications',
  description: 'This channel is used for important Ojaewa notifications.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  enableLights: true,
);

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
  bool _localNotificationsInitialized = false;
  bool _messageHandlersSetUp = false;

  /// Call this once at app startup to create the channel early
  Future<void> createChannelEarly() async {
    if (kIsWeb) return;
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } catch (_) {}
  }

  Future<void> _initLocalNotifications() async {
    if (_localNotificationsInitialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // User tapped a local notification - call tap callback with data
        final payload = response.payload;
        if (payload != null && _onNotificationTapCallback != null) {
          try {
            final data = Map<String, dynamic>.from(
              {for (final e in payload.split('&')) e.split('=')[0]: e.split('=')[1]},
            );
            _onNotificationTapCallback?.call(data);
          } catch (_) {
            _onNotificationTapCallback?.call({'type': payload});
          }
        }
      },
    );

    // Create Android notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _localNotificationsInitialized = true;
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;
    if (!_localNotificationsInitialized) return;
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Build payload from message data for tap navigation
    final payloadEntries = message.data.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    try {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: payloadEntries.isNotEmpty ? payloadEntries : null,
      );
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

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
    _initialized = false;
    _messageHandlersSetUp = false;

    // Check if permission is already granted - if so, skip the prompt
    final existing = await _messaging.getNotificationSettings();
    bool isGranted = existing.authorizationStatus == AuthorizationStatus.authorized ||
        existing.authorizationStatus == AuthorizationStatus.provisional;

    if (!isGranted) {
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
        isGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (e) {
        debugPrint('Error requesting FCM permissions: $e');
      }
    }

    if (isGranted) {
      try {
        // For iOS, it's safer to wait for APNs token before getting FCM token
        if (!kIsWeb && Platform.isIOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          int retryCount = 0;
          while (apnsToken == null && retryCount < 5) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _messaging.getAPNSToken();
            retryCount++;
            debugPrint('Waiting for APNs token (attempt $retryCount)...');
          }
          if (apnsToken == null) {
            debugPrint('APNs token is still null after retries');
          }
        }

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
        await _setupMessageHandlers();

        // Register background handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        
        _initialized = true;
        return _fcmToken != null;
      } catch (e) {
        debugPrint('FCM initialization error: $e');
      }
    } else {
      debugPrint('FCM Permission denied');
    }
    return false;
  }

  /// Attempt to register token without prompting (Android auto-grants).
  Future<bool> initializeWithoutPrompt() async {
    if (_initialized && _fcmToken != null) {
      return true;
    }
    _initialized = false;
    _messageHandlersSetUp = false;

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
        await _setupMessageHandlers();
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        _initialized = true;
        return _fcmToken != null;
      }
    } catch (e) {
      debugPrint('FCM silent init error: $e');
    }
    return false;
  }

  /// Register onMessage listener early so foreground notifications work
  /// even before the user explicitly enables push in settings.
  Future<void> setupForegroundHandler() async {
    await _setupMessageHandlers();
  }

  /// Setup foreground and background message handlers
  Future<void> _setupMessageHandlers() async {
    if (_messageHandlersSetUp) return;
    _messageHandlersSetUp = true;
    await _initLocalNotifications();

    // On iOS, tell FCM to show notification while app is in foreground too
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      
      // Prevent duplicates: Only show manual local notification on Android
      // because iOS shows the banner automatically via setForegroundNotificationPresentationOptions
      if (Platform.isAndroid) {
        _showLocalNotification(message);
      }

      // Also call the in-app banner callback
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
      RemoteLogger.error('FCM Token Registration Failed', context: {
        'token': token,
        'error': e.toString(),
      });
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
