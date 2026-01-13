import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/user_profile.dart';

class UserApi {
  UserApi(this._dio);

  final Dio _dio;

  Future<UserProfile> getMe() async {
    try {
      final res = await _dio.get('/api/profile');
      return _extractUser(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      final res = await _dio.put(
        '/api/profile',
        data: {
          // New docs expect firstname/lastname, not name.
          // The UI currently provides a single name string, so we split best-effort.
          ..._splitName(name),
          'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      return _extractUser(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

Map<String, dynamic> _splitName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return {'firstname': '', 'lastname': ''};
  if (parts.length == 1) return {'firstname': parts.first, 'lastname': ''};
  return {
    'firstname': parts.first,
    'lastname': parts.sublist(1).join(' '),
  };
}

UserProfile _extractUser(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return UserProfile.fromJson(inner);
    return UserProfile.fromJson(data);
  }
  throw const FormatException('Unexpected user response');
}
