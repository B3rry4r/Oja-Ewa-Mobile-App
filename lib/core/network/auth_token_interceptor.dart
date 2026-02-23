import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_providers.dart';
import '../constants/network_constants.dart';
import '../storage/storage_providers.dart';

/// Adds `Authorization: Bearer <token>` when available.
///
/// Also prevents hitting authenticated endpoints when the user is logged out.
/// This avoids noisy 401 bursts after logout while screens/providers are still
/// rebuilding.
///
/// Handles 401 responses from server (invalid/expired token) by clearing auth state.
class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._ref);

  final Ref _ref;
  
  // Track if we're already handling a 401 to prevent multiple logouts
  bool _handlingUnauthorized = false;

  static const _publicPrefixes = <String>[
    '/api/products/public/',
    '/api/products/browse',
    '/api/products/search',
    '/api/categories',
    '/api/blogs',
    '/api/adverts',
    '/api/sellers/',
    '/api/sustainability',

    // school registration (public)
    '/api/school-registrations',

    // auth
    '/api/login',
    '/api/register',
    '/api/oauth/google',
    '/api/password/forgot',
    '/api/password/reset',
  ];

  bool _isPublicPath(String path) {
    for (final p in _publicPrefixes) {
      if (path.startsWith(p)) return true;
    }
    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      String? token = _ref.read(accessTokenProvider);

      // Fallback: if auth state isn't loaded yet, read from secure storage.
      token ??= await _ref.read(secureTokenStorageProvider).readAccessToken();

      final path = options.path;

      if (token == null || token.isEmpty) {
        // Allow public endpoints without auth.
        if (_isPublicPath(path)) {
          handler.next(options);
          return;
        }

        // Block authenticated endpoints when logged out.
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'Unauthenticated (client blocked request)'},
            ),
          ),
          true,
        );
        return;
      }

      options.headers[NetworkConstants.authorizationHeader] = NetworkConstants.bearer(token);
    } catch (_) {
      // Never block a request on token read errors.
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized from the LARAVEL API only.
    //
    // IMPORTANT: The AI backend (ojaewa-ai-production-*.up.railway.app) may
    // return 401 for its own reasons (e.g. different token validation).
    // We must NOT sign the user out because of AI backend 401s — only
    // a 401 from the Laravel API on an authenticated endpoint should do that.
    //
    // We identify Laravel API requests by the path starting with '/api/'.
    // AI backend paths start with '/ai/'.
    if (err.response?.statusCode == 401 && !_handlingUnauthorized) {
      final path = err.requestOptions.path;

      // Only act on Laravel API paths (/api/...), not AI paths (/ai/...)
      final isLaravelPath = path.startsWith('/api/');

      // Don't logout for login/register failures or public endpoints
      if (isLaravelPath &&
          !_isPublicPath(path) &&
          !path.contains('/api/login') &&
          !path.contains('/api/register')) {
        _handlingUnauthorized = true;

        try {
          // Clear the stored token from secure storage
          await _ref.read(secureTokenStorageProvider).deleteAccessToken();
          // Sign out locally — this sets state to AuthUnauthenticated.
          // Do NOT call _ref.invalidate(authControllerProvider) — that resets
          // the controller to AuthUnknown and breaks the bootstrap flow.
          await _ref
              .read(authControllerProvider.notifier)
              .signOutLocal();
        } catch (_) {
          // Ignore errors during cleanup
        } finally {
          _handlingUnauthorized = false;
        }
      }
    }

    handler.next(err);
  }
}
