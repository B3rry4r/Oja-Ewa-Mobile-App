import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import 'logout_endpoints.dart';

/// Low-level API client for auth endpoints.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<String> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(
        '/api/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Docs show token is returned; backend shape may be:
      // {"token":"..."} or {"data": {"token":"..."}}
      final data = res.data;
      final token = _extractToken(data);
      if (token == null || token.isEmpty) {
        throw const FormatException('Token missing in response');
      }
      return token;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<String> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/api/register',
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
        },
      );

      final token = _extractToken(res.data);
      if (token == null || token.isEmpty) {
        throw const FormatException('Token missing in response');
      }
      return token;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Best-effort server logout.
  ///
  /// Because the API docs do not currently document user logout, we try a small
  /// set of common endpoints. Any failure should NOT block local sign-out.
  Future<void> logout() async {
    // Backend contract: POST /api/logout
    await _dio.post(userLogoutPath);
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(
        '/api/password/forgot',
        data: {'email': email},
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.post(
        '/api/password/reset',
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<String> googleSignIn({required String idToken}) async {
    try {
      final res = await _dio.post(
        '/api/oauth/google',
        data: {
          'token': idToken,
        },
      );

      final token = _extractToken(res.data);
      if (token == null || token.isEmpty) {
        throw const FormatException('Token missing in response');
      }
      return token;
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

String? _extractToken(dynamic data) {
  if (data is Map<String, dynamic>) {
    final direct = data['token'];
    if (direct is String) return direct;

    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final t = nested['token'];
      if (t is String) return t;
    }
  }
  return null;
}
