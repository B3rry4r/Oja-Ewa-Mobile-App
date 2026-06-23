import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_environment.dart';
import '../constants/app_urls.dart';
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

  /// When the live session token was last (re)minted via [setTokens] (login,
  /// register, Google sign-in, refresh). The 401 interceptor reads this to
  /// suppress an immediate sign-out in the brief window right after sign-in:
  /// the post-login burst of authed calls can race the just-set token and a
  /// transient 401 there must NOT undo the login the user just completed
  /// ("logged in, then bounced back to onboarding").
  DateTime? sessionEstablishedAt;

  /// Grace window after a session is minted during which a 401 on an
  /// authenticated endpoint is treated as a race against the fresh token rather
  /// than a genuine expiry.
  static const Duration freshSessionGrace = Duration(seconds: 8);

  bool get isSessionFresh {
    final at = sessionEstablishedAt;
    return at != null && DateTime.now().difference(at) < freshSessionGrace;
  }

  Future<void> loadFromStorage() async {
    try {
      final storage = ref.read(secureTokenStorageProvider);
      final token = await storage.readAccessToken();
      // Refresh token is loaded so it survives restarts and is available to
      // refreshSession(); it is kept in secure storage only.
      await storage.readRefreshToken();
      if (token == null || token.isEmpty) {
        AppEnv.accessToken = null;
        state = const AuthUnauthenticated();
      } else {
        AppEnv.accessToken = token; // Set for Pusher authorization
        state = AuthAuthenticated(accessToken: token);
      }
    } catch (_) {
      AppEnv.accessToken = null;
      state = const AuthUnauthenticated();
    }
  }

  /// Persist both the access and refresh tokens and mark the session
  /// authenticated.
  Future<void> setTokens(String accessToken, String refreshToken) async {
    final storage = ref.read(secureTokenStorageProvider);
    await storage.writeAccessToken(accessToken);
    if (refreshToken.isNotEmpty) {
      await storage.writeRefreshToken(refreshToken);
    }
    AppEnv.accessToken = accessToken; // Set for Pusher authorization
    sessionEstablishedAt = DateTime.now();
    state = AuthAuthenticated(accessToken: accessToken);
  }

  /// Exchange the stored refresh token for a fresh access/refresh pair via
  /// WAWU ID. On any failure the local session is cleared.
  Future<void> refreshSession() async {
    final storage = ref.read(secureTokenStorageProvider);
    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await signOutLocal();
        return;
      }

      final res = await Dio().post(
        '${AppUrls.wawuIdBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final body = res.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      final newAccess = data is Map<String, dynamic> ? data['accessToken'] : null;
      final newRefresh = data is Map<String, dynamic> ? data['refreshToken'] : null;

      if (newAccess is! String || newAccess.isEmpty) {
        await signOutLocal();
        return;
      }

      await setTokens(newAccess, newRefresh is String ? newRefresh : refreshToken);
    } catch (_) {
      await signOutLocal();
    }
  }

  Future<void> signOutLocal() async {
    final storage = ref.read(secureTokenStorageProvider);
    await storage.deleteAccessToken();
    await storage.deleteRefreshToken();
    AppEnv.accessToken = null; // Clear Pusher authorization
    sessionEstablishedAt = null;
    state = const AuthUnauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
