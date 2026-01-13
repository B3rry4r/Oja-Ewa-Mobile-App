import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Converts Dio errors into app-level exceptions.
AppException mapDioError(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return const UnauthorizedException();
    }

    final data = error.response?.data;
    final message = _sanitizeMessage(_extractMessage(data) ?? error.message ?? 'Network error', statusCode);

    if (statusCode != null && statusCode >= 500) {
      return ServerException(message, code: statusCode.toString(), cause: error);
    }

    return NetworkException(message, code: statusCode?.toString(), cause: error);
  }

  return AppException('Unexpected error', cause: error);
}

String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    // Common API formats.
    if (data['message'] is String) return data['message'] as String;
    if (data['error'] is String) return data['error'] as String;

    // Laravel validation errors sometimes look like: { errors: { field: [..] } }
    final errors = data['errors'];
    if (errors is Map<String, dynamic>) {
      final first = errors.values.whereType<List>().expand((e) => e).whereType<String>().firstOrNull;
      if (first != null) return first;
    }
  }
  if (data is String) return data;
  return null;
}

String _sanitizeMessage(String message, int? statusCode) {
  final lower = message.toLowerCase();

  // Avoid dumping HTML pages into the UI.
  if (lower.contains('<!doctype html') || lower.contains('<html')) {
    if (statusCode == 404) return 'Endpoint not found (404). Please update the app or contact support.';
    return 'Unexpected server response. Please try again.';
  }

  if (statusCode == 404) {
    return message.isNotEmpty ? message : 'Not found (404).';
  }

  return message;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
