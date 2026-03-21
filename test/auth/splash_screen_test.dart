import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_state.dart';
import 'package:ojaewa/features/auth/presentation/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('navigates to onboarding after splash delay when unauthenticated', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
          ],
          child: _buildApp(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsOneWidget);
    });

    testWidgets('navigates to home after splash delay when authenticated', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_AuthenticatedAuthController.new),
          ],
          child: _buildApp(),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}

Widget _buildApp() {
  return MaterialApp(
    routes: {
      AppRoutes.splash: (_) => const SplashScreen(),
      AppRoutes.home: (_) => const Scaffold(body: Center(child: Text('Home'))),
      AppRoutes.onboarding: (_) =>
          const Scaffold(body: Center(child: Text('Onboarding'))),
    },
    initialRoute: AppRoutes.splash,
  );
}

class _AuthenticatedAuthController extends AuthController {
  @override
  AuthState build() => const AuthAuthenticated(accessToken: 'token');
}

class _UnauthenticatedAuthController extends AuthController {
  @override
  AuthState build() => const AuthUnauthenticated();
}
