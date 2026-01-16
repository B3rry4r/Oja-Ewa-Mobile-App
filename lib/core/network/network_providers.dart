import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../auth/auth_controller.dart';

/// Kicks off loading auth state from secure storage at app start.
///
/// This is separated so we can trigger it from a small bootstrap widget.
final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authControllerProvider.notifier).loadFromStorage();
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
