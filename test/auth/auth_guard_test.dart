import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_guard.dart';
import 'package:ojaewa/core/auth/auth_state.dart';

void main() {
  group('AuthGuard', () {
    testWidgets('renders protected child when authenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              _AuthenticatedAuthController.new,
            ),
          ],
          child: _buildApp(),
        ),
      );

      expect(find.text('Protected'), findsOneWidget);
      expect(find.text('Onboarding'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator while auth state is unknown', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_UnknownAuthController.new),
          ],
          child: _buildApp(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Protected'), findsNothing);
      expect(find.text('Onboarding'), findsNothing);

      await tester.pump();
      expect(find.text('Onboarding'), findsNothing);
    });

    testWidgets('redirects to onboarding when unauthenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              _UnauthenticatedAuthController.new,
            ),
          ],
          child: _buildApp(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Protected'), findsNothing);

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsOneWidget);
      expect(find.text('Protected'), findsNothing);
    });
  });
}

Widget _buildApp() {
  return MaterialApp(
    routes: {
      AppRoutes.onboarding: (_) =>
          const Scaffold(body: Center(child: Text('Onboarding'))),
    },
    home: const AuthGuard(
      child: Scaffold(body: Center(child: Text('Protected'))),
    ),
  );
}

class _AuthenticatedAuthController extends AuthController {
  @override
  AuthState build() => const AuthAuthenticated(accessToken: 'token-123');
}

class _UnknownAuthController extends AuthController {
  @override
  AuthState build() => const AuthUnknown();
}

class _UnauthenticatedAuthController extends AuthController {
  @override
  AuthState build() => const AuthUnauthenticated();
}
