import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_urls.dart';
import '../constants/network_constants.dart';
import 'auth_token_interceptor.dart';
import 'debug_log_interceptor.dart';

/// Holds two separate Dio instances:
/// - Laravel API
/// - Node AI API
class DioClients {
  DioClients({required this.laravel, required this.ai});

  final Dio laravel;
  final Dio ai;
}

final dioClientsProvider = Provider<DioClients>((ref) {
  Dio build(String baseUrl) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: NetworkConstants.connectTimeout,
      // Web warning: sendTimeout is only meaningful when sending a request body.
      // Leaving this unset avoids noisy logs on web.
      // sendTimeout: NetworkConstants.sendTimeout,
      receiveTimeout: NetworkConstants.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(options);
    dio.interceptors.add(AuthTokenInterceptor(ref));

    // Debug-only request logging
    // (no request bodies to avoid leaking PII)
    dio.interceptors.add(DebugLogInterceptor());

    // Add additional interceptors here later (sentry, retry, etc.)
    return dio;
  }

  return DioClients(
    laravel: build(AppUrls.laravelBaseUrl),
    ai: build(AppUrls.aiBaseUrl),
  );
});

final laravelDioProvider = Provider<Dio>((ref) => ref.watch(dioClientsProvider).laravel);
final aiDioProvider = Provider<Dio>((ref) => ref.watch(dioClientsProvider).ai);
