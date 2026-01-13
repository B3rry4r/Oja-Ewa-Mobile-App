import 'dart:core';

class NetworkConstants {
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Header used by both Laravel + Node AI services.
  static const String authorizationHeader = 'Authorization';

  /// Standard `Bearer {token}` format.
  static String bearer(String token) => 'Bearer $token';
}
