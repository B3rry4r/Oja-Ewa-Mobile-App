import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Simple debug logger to help verify which endpoints are being hit.
///
/// Avoids logging request/response bodies to keep PII out of logs.
class DebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] --> ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] <-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final status = err.response?.statusCode;
      final msg = _shortMessage(err.response?.data) ?? err.message;
      debugPrint(
        '[HTTP] <-- ERR $status ${err.requestOptions.method} ${err.requestOptions.uri} :: ${msg ?? ''}',
      );
    }
    handler.next(err);
  }

  String? _shortMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty && v.first is String) return v.first as String;
        }
      }
    }
    if (data is String) {
      final lower = data.toLowerCase();
      if (lower.contains('<html') || lower.contains('<!doctype html')) return 'HTML error response';
      return data.length > 160 ? '${data.substring(0, 160)}…' : data;
    }
    return null;
  }
}
