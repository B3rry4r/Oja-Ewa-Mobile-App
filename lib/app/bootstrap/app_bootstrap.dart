import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_providers.dart';

/// Runs one-time startup tasks (e.g., load auth token) before rendering app UI.
///
/// Shows a loading screen until auth state is definitively known
/// (either [AuthAuthenticated] or [AuthUnauthenticated]).
/// This prevents the navigator from rendering routes before it knows
/// whether the user is logged in, which would cause navigation conflicts.
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(authBootstrapProvider);

    return bootstrap.when(
      // Auth state is resolved — render the app
      data: (_) => child,
      // Still loading from secure storage — show a neutral loading screen
      loading: () => const Material(
        color: Color(0xFFFFF8F1),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
          ),
        ),
      ),
      // Something went very wrong — still show the app so user isn't stuck
      error: (err, st) => child,
    );
  }
}
