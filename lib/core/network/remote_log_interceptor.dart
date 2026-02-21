import 'package:dio/dio.dart';
import '../logger/remote_logger.dart';

/// Interceptor that automatically sends API errors to the remote logger.
class RemoteLogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Only log actual API errors (4xx, 5xx)
    final response = err.response;
    if (response != null) {
      RemoteLogger.error(
        'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
        context: {
          'status': response.statusCode,
          'statusMessage': response.statusMessage,
          'data': response.data,
          'headers': response.headers.map,
          'queryParameters': err.requestOptions.queryParameters,
        },
      );
    } else {
      // Network timeout or connection issues
      RemoteLogger.warn(
        'Network Error: ${err.requestOptions.method} ${err.requestOptions.path}',
        context: {
          'type': err.type.toString(),
          'message': err.message,
        },
      );
    }
    
    return super.onError(err, handler);
  }
}
