import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ojaewa/features/auth/presentation/screens/new_password_screen.dart';
import 'package:ojaewa/features/auth/presentation/screens/password_reset_args.dart';
import 'package:ojaewa/features/auth/presentation/screens/password_reset_success_screen.dart';
import 'package:ojaewa/features/auth/presentation/screens/reset_password_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('overflow regressions', () {
    testWidgets('reset password screen fits on a small phone', (tester) async {
      await pumpAtSize(
        tester,
        const Size(320, 640),
        const ProviderScope(child: MaterialApp(home: ResetPasswordScreen())),
      );
    });

    testWidgets('new password screen fits on a small phone', (tester) async {
      await pumpAtSize(
        tester,
        const Size(320, 640),
        MaterialApp(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const ProviderScope(child: NewPasswordScreen()),
            );
          },
          initialRoute: '/new-password',
          routes: const {},
          onGenerateInitialRoutes: (initialRoute) {
            return [
              MaterialPageRoute<void>(
                settings: const RouteSettings(
                  name: '/new-password',
                  arguments: NewPasswordArgs(
                    email: 'tester@example.com',
                    token: 'reset-token',
                  ),
                ),
                builder: (_) => const ProviderScope(child: NewPasswordScreen()),
              ),
            ];
          },
        ),
      );
    });

    testWidgets('password reset success screen fits on a small phone', (
      tester,
    ) async {
      await pumpAtSize(
        tester,
        const Size(320, 640),
        const MaterialApp(home: PasswordResetSuccessScreen()),
      );
    });
  });
}

Future<void> pumpAtSize(WidgetTester tester, Size size, Widget child) async {
  final errors = <FlutterErrorDetails>[];
  final previousOnError = FlutterError.onError;

  FlutterError.onError = (details) {
    errors.add(details);
  };

  addTearDown(() {
    FlutterError.onError = previousOnError;
  });

  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: child,
    ),
  );
  await tester.pumpAndSettle();
  FlutterError.onError = previousOnError;

  bool isBadLayout(FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    return message.contains('RenderFlex overflowed') ||
        message.contains('RenderFlex children have non-zero flex') ||
        message.contains('Cannot hit test a render box with no size') ||
        message.contains('unbounded') ||
        message.contains('A RenderFlex overflowed');
  }

  final badLayouts = errors.where(isBadLayout).toList();
  if (badLayouts.isEmpty) {
    return;
  }

  final first = badLayouts.first;
  fail(
    'Layout error detected:\n${first.exceptionAsString()}\n\nDetails:\n$first',
  );
}
