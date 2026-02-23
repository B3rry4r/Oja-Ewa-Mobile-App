import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/auth/auth_controller.dart';
import 'core/notifications/fcm_service.dart';
import 'firebase_options.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.notification?.title}');
}

Future<void> _bootstrap() async {
  // ensureInitialized MUST be called in the same zone as runApp.
  // That's why all setup is inside _bootstrap(), which is called
  // from inside runZonedGuarded below.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics & Analytics — NOT supported on web
  if (!kIsWeb) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught Flutter framework errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught async errors (outside Flutter framework) to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Register background FCM handler (not supported on web)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Load auth token from secure storage before building the widget tree.
  final container = ProviderContainer();
  await container.read(authControllerProvider.notifier).loadFromStorage();

  // Create FCM notification channel early for Android (not supported on web)
  if (!kIsWeb) {
    try {
      await container.read(fcmServiceProvider).createChannelEarly();
    } catch (e) {
      debugPrint('Error creating FCM channel: $e');
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}

void main() {
  // runZonedGuarded wraps EVERYTHING including ensureInitialized and runApp
  // so they all run in the same zone — required by Flutter on web.
  runZonedGuarded(
    _bootstrap,
    (error, stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      debugPrint('Uncaught error: $error\n$stack');
    },
  );
}
