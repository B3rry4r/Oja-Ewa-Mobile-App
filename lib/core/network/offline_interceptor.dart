import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_providers.dart';

/// Blocks network requests when the device is offline.
class OfflineInterceptor extends Interceptor {
  OfflineInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivity = _ref.read(connectivityProvider).value;
    final isOnline = connectivity != null && connectivity.isNotEmpty && !connectivity.contains(ConnectivityResult.none);

    if (!isOnline) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }
}
