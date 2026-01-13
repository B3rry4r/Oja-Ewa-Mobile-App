import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_providers.dart';

/// Runs one-time startup tasks (e.g., load auth token) before rendering app UI.
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(authBootstrapProvider);

    return bootstrap.when(
      data: (_) => child,
      loading: () => const Material(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Material(
        child: Center(
          child: Text('Bootstrap error: $err'),
        ),
      ),
    );
  }
}
