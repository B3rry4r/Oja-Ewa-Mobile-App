import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_environment.dart';

/// Service to send client-side logs to the backend server for debugging.
class RemoteLogger {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppEnv.apiBaseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  /// Sends a log entry to the server.
  /// [level] can be 'error', 'info', 'warning', or 'debug'.
  static Future<void> log(String level, String message, {Map<String, dynamic>? context}) async {
    // Only log in debug/profile mode or specific environments if desired
    // For now, we log everything as requested to catch physical device issues.
    
    final token = AppEnv.accessToken;
    
    try {
      debugPrint('📤 Sending remote log: [$level] $message');
      
      await _dio.post(
        '/api/logs/client',
        data: {
          'level': level,
          'message': message,
          'context': {
            'platform': defaultTargetPlatform.toString(),
            'isWeb': kIsWeb,
            if (context != null) ...context,
          },
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      // We don't throw here to avoid infinite loops or crashing the app due to logging failure
      debugPrint('⚠️ Could not send remote log: $e');
    }
  }

  static Future<void> error(String message, {Map<String, dynamic>? context}) => 
      log('error', message, context: context);

  static Future<void> info(String message, {Map<String, dynamic>? context}) => 
      log('info', message, context: context);

  static Future<void> warn(String message, {Map<String, dynamic>? context}) => 
      log('warning', message, context: context);
}
