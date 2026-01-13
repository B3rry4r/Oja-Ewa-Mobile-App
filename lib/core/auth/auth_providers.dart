import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'auth_state.dart';

/// Convenience provider to access token if authenticated.
final accessTokenProvider = Provider<String?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    AuthAuthenticated(:final accessToken) => accessToken,
    _ => null,
  };
});
