import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';
import 'auth_state.dart';

/// Owns the app's authentication session.
///
/// - Loads token from secure storage on startup
/// - Exposes token to network interceptors
/// - Provides sign-in/out helpers
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Start as unknown; caller should trigger `loadFromStorage()`.
    return const AuthUnknown();
  }

  Future<void> loadFromStorage() async {
    final token = await ref.read(secureTokenStorageProvider).readAccessToken();
    if (token == null || token.isEmpty) {
      state = const AuthUnauthenticated();
    } else {
      state = AuthAuthenticated(accessToken: token);
    }
  }

  Future<void> setAccessToken(String token) async {
    await ref.read(secureTokenStorageProvider).writeAccessToken(token);
    state = AuthAuthenticated(accessToken: token);
  }

  Future<void> signOutLocal() async {
    await ref.read(secureTokenStorageProvider).deleteAccessToken();
    state = const AuthUnauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
