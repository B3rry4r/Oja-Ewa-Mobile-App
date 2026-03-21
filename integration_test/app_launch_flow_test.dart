import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/app/app.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_state.dart';
import 'package:ojaewa/core/audio/audio_controller.dart';
import 'package:ojaewa/core/notifications/fcm_service.dart';
import 'package:ojaewa/features/categories/domain/category_catalog.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unauthenticated app launch reaches onboarding flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_FakeAuthController.new),
          audioControllerProvider.overrideWith(_FakeAudioController.new),
          allCategoriesProvider.overrideWithValue(
            const AsyncData(
              CategoryCatalog(
                categories: {},
                formOptions: CategoryFormOptions(
                  fabrics: [],
                  styles: [],
                  tribes: [],
                ),
              ),
            ),
          ),
          fcmServiceProvider.overrideWithValue(
            FCMService(messaging: _MockFirebaseMessaging()),
          ),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('The Pan-African\nBeauty Market'), findsOneWidget);
  });
}

class _FakeAuthController extends AuthController {
  @override
  AuthState build() => const AuthUnauthenticated();
}

class _FakeAudioController extends AudioController {
  @override
  bool build() => false;

  @override
  Future<void> initialize() async {}
}

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
