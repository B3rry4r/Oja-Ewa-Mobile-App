import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks device connectivity with initial state.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  if (!kIsWeb && Platform.isIOS) {
    // Avoid launch-time access to connectivity_plus on iOS.
    yield const [ConnectivityResult.other];
    return;
  }

  final connectivity = Connectivity();
  try {
    yield await connectivity.checkConnectivity();
  } catch (_) {
    yield const [ConnectivityResult.other];
    return;
  }

  try {
    yield* connectivity.onConnectivityChanged;
  } catch (_) {
    yield const [ConnectivityResult.other];
  }
});

/// Returns true when device has network connectivity.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider).value;
  if (connectivity == null) return true;
  return connectivity.isNotEmpty &&
      !connectivity.contains(ConnectivityResult.none);
});
