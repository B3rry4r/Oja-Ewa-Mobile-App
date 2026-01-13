import 'package:flutter/foundation.dart';

@immutable
class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException(message: $message, code: $code, cause: $cause)';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.cause});
}
