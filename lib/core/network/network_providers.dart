import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

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
