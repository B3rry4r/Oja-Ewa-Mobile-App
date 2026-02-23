import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ojaewa/app/app.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_state.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Start in a known unauthenticated state so the splash screen
          // navigates to onboarding without hitting secure storage.
          authControllerProvider.overrideWith(() => _FakeAuthController()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // Basic smoke test: app builds without exceptions.
    expect(find.byType(MaterialApp), findsOneWidget);

    final exception = tester.takeException();
    expect(exception, isNull);
  });
}

class _FakeAuthController extends AuthController {
  @override
  AuthState build() => const AuthUnauthenticated();
}
