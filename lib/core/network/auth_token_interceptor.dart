import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../constants/network_constants.dart';

/// Adds `Authorization: Bearer <token>` when available.
class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(accessTokenProvider);
    if (token != null && token.isNotEmpty) {
      options.headers[NetworkConstants.authorizationHeader] = NetworkConstants.bearer(token);
    }
    handler.next(options);
  }
}
