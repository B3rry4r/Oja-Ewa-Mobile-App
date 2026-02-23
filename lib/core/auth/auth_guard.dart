import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router/app_router.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

/// A widget that guards its child and redirects to onboarding if not authenticated.
///
/// Handles three states:
/// - [AuthUnknown]: show loading spinner (auth not yet resolved — should be
///   extremely rare since main() calls loadFromStorage() before runApp).
/// - [AuthUnauthenticated]: redirect to onboarding.
/// - [AuthAuthenticated]: show the child screen.
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    switch (authState) {
      case AuthAuthenticated():
        return child;

      case AuthUnknown():
        // Auth state not yet resolved — show loading rather than redirecting.
        // This is a safety net; in practice auth is resolved before runApp().
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case AuthUnauthenticated():
        // Schedule navigation after build to avoid calling Navigator during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.onboarding,
              (route) => false,
            );
          }
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}

/// Helper function to wrap a screen with auth guard.
Widget withAuthGuard(Widget screen) => AuthGuard(child: screen);
