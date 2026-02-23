import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';

/// Ensures auth state is fully resolved before the app UI renders.
///
/// If the state is still [AuthUnknown] (e.g. after a logout that invalidated
/// the controller), this will call [loadFromStorage] so the controller
/// transitions to either [AuthAuthenticated] or [AuthUnauthenticated].
/// The provider does NOT resolve until the state is definitively known.
final authBootstrapProvider = FutureProvider<void>((ref) async {
  final authState = ref.read(authControllerProvider);

  // If state is unknown (e.g. fresh controller after invalidation),
  // load the token from storage before proceeding.
  if (authState is AuthUnknown) {
    await ref.read(authControllerProvider.notifier).loadFromStorage();
  }

  // Now watch so AppBootstrap rebuilds if auth state changes later.
  ref.watch(authControllerProvider);
});

/// Tracks device connectivity with initial state.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

/// Returns true when device has network connectivity.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider).value;
  if (connectivity == null) return false;
  return connectivity.isNotEmpty && !connectivity.contains(ConnectivityResult.none);
});
