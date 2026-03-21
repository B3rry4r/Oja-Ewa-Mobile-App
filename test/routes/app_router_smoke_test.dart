import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/shell/app_shell.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_state.dart';
import 'package:ojaewa/core/audio/audio_controller.dart';
import 'package:ojaewa/core/notifications/fcm_service.dart';
import 'package:ojaewa/features/auth/presentation/screens/create_account_screen.dart';
import 'package:ojaewa/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:ojaewa/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:ojaewa/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:ojaewa/features/categories/domain/category_catalog.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';

void main() {
  group('AppRouter smoke', () {
    testWidgets('builds public auth routes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: _buildRouteBody(AppRoutes.signIn)),
      );
      expect(find.byType(SignInScreen), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(child: _buildRouteBody(AppRoutes.createAccount)),
      );
      expect(find.byType(CreateAccountScreen), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(child: _buildRouteBody(AppRoutes.resetPassword)),
      );
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });

    testWidgets('redirects guarded routes to onboarding when unauthenticated', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: const SizedBox(),
          ),
        ),
      );

      navigatorKey.currentState!.pushNamed(AppRoutes.addresses);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('falls back to the app shell for unknown routes', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
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
          child: MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: const SizedBox(),
          ),
        ),
      );

      navigatorKey.currentState!.pushNamed('/does-not-exist');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });
  });
}

Widget _buildRouteBody(String routeName) {
  final route = AppRouter.onGenerateRoute(RouteSettings(name: routeName));
  final pageRoute = route as MaterialPageRoute<void>;
  return MaterialApp(home: Builder(builder: pageRoute.builder));
}

class _UnauthenticatedAuthController extends AuthController {
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
