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

/// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Analytics & Crashlytics — NOT supported on web
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

  // Ensure auth token is loaded before any network calls.
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

  // Wrap the app in runZonedGuarded so ALL async errors (even those outside
  // Flutter's zone) are caught and forwarded to Crashlytics.
  runZonedGuarded(
    () => runApp(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    ),
    (error, stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      debugPrint('Uncaught error: $error\n$stack');
    },
  );
}
