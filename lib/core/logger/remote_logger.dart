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

  static bool _isLogging = false;

  /// Sends a log entry to the server.
  /// [level] can be 'error', 'info', 'warning', or 'debug'.
  static Future<void> log(String level, String message, {Map<String, dynamic>? context}) async {
    if (_isLogging) return; // Prevent infinite loops
    _isLogging = true;
    
    final token = AppEnv.accessToken;
    
    try {
      // debugPrint('📤 Sending remote log: [$level] $message');
      
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
      // Fail silently to avoid recursion/crashing
    } finally {
      _isLogging = false;
    }
  }

  static Future<void> error(String message, {Map<String, dynamic>? context}) => 
      log('error', message, context: context);

  static Future<void> info(String message, {Map<String, dynamic>? context}) => 
      log('info', message, context: context);

  static Future<void> warn(String message, {Map<String, dynamic>? context}) => 
      log('warning', message, context: context);
}
