import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../auth/auth_controller.dart';

/// Resolves immediately — auth is already loaded from storage in main()
/// before the ProviderContainer is passed to the widget tree.
/// This provider exists only to let AppBootstrap await readiness.
final authBootstrapProvider = FutureProvider<void>((ref) async {
  // Auth token is already loaded in main() via loadFromStorage().
  // Watching authControllerProvider here ensures we wait until it is ready.
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
