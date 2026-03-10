import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/startup_debug_flags.dart';
import 'core/auth/auth_controller.dart';
import 'core/notifications/fcm_service.dart';
import 'firebase_options.dart';

bool _firebaseInitialized = false;
bool _crashlyticsInitialized = false;

Future<void> _recordStartupError(
  Object error,
  StackTrace stack, {
  required bool fatal,
}) async {
  debugPrint('Startup error: $error\n$stack');

  if (kIsWeb || !_firebaseInitialized || !_crashlyticsInitialized) {
    return;
  }

  try {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  } catch (crashlyticsError, crashlyticsStack) {
    debugPrint(
      'Failed to record Crashlytics error: $crashlyticsError\n$crashlyticsStack',
    );
  }
}

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;
  } catch (error, stack) {
    debugPrint('Background Firebase initialization failed: $error\n$stack');
    return;
  }
  debugPrint('Background message: ${message.notification?.title}');
}

Future<void> _bootstrap() async {
  // ensureInitialized MUST be called in the same zone as runApp.
  // That's why all setup is inside _bootstrap(), which is called
  // from inside runZonedGuarded below.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;
  } catch (error, stack) {
    debugPrint('Firebase initialization failed: $error\n$stack');
  }

  // Crashlytics & Analytics — NOT supported on web
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _recordStartupError(
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _recordStartupError(error, stack, fatal: true);
    return true;
  };

  if (!kIsWeb && _firebaseInitialized) {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      _crashlyticsInitialized = true;
    } catch (error, stack) {
      debugPrint('Crashlytics initialization failed: $error\n$stack');
    }

    if (!StartupDebugFlags.shouldDisableFcmAtStartup) {
      try {
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      } catch (error, stack) {
        await _recordStartupError(error, stack, fatal: false);
      }
    } else {
      debugPrint('iOS startup isolation: skipping FCM background handler');
    }
  }

  // Kick off auth restoration without blocking first paint.
  final container = ProviderContainer();
  unawaited(() async {
    try {
      await container.read(authControllerProvider.notifier).loadFromStorage();
    } catch (error, stack) {
      await _recordStartupError(error, stack, fatal: false);
    }
  }());

  // Create FCM notification channel early for Android (not supported on web)
  if (!kIsWeb && !StartupDebugFlags.shouldDisableLocalNotificationsAtStartup) {
    try {
      await container.read(fcmServiceProvider).createChannelEarly();
    } catch (e) {
      debugPrint('Error creating FCM channel: $e');
    }
  } else if (StartupDebugFlags.shouldDisableLocalNotificationsAtStartup) {
    debugPrint('iOS startup isolation: skipping local notifications setup');
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

void main() {
  // runZonedGuarded wraps EVERYTHING including ensureInitialized and runApp
  // so they all run in the same zone — required by Flutter on web.
  runZonedGuarded(_bootstrap, (error, stack) async {
    await _recordStartupError(error, stack, fatal: true);
  });
}
