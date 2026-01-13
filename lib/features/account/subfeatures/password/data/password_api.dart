import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';

class PasswordApi {
  PasswordApi(this._dio);

  final Dio _dio;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.put(
        '/api/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
