import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router/app_router.dart';
import 'auth_providers.dart';

/// A widget that guards its child and redirects to onboarding if not authenticated.
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(accessTokenProvider);
    
    if (token == null || token.isEmpty) {
      // Schedule navigation after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.onboarding,
            (route) => false,
          );
        }
      });
      
      // Show loading while redirecting
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}

/// Helper function to wrap a screen with auth guard
Widget withAuthGuard(Widget screen) => AuthGuard(child: screen);
