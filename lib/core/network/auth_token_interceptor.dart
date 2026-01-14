import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../constants/network_constants.dart';
import '../storage/storage_providers.dart';

/// Adds `Authorization: Bearer <token>` when available.
///
/// Important: Some feature providers can fire network calls very early.
/// To avoid missing the token during app bootstrap, we try the in-memory
/// session first, then fall back to secure storage.
class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      String? token = _ref.read(accessTokenProvider);

      // Fallback: if auth state isn't loaded yet, read from secure storage.
      token ??= await _ref.read(secureTokenStorageProvider).readAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers[NetworkConstants.authorizationHeader] = NetworkConstants.bearer(token);
      }
    } catch (_) {
      // Never block a request on token read errors.
    }

    handler.next(options);
  }
}
