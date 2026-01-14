import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';

class SustainabilityApi {
  SustainabilityApi(this._dio);

  final Dio _dio;

  /// List all sustainability initiatives with optional filters
  Future<Map<String, dynamic>> listInitiatives({
    String? type,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (type != null) queryParams['type'] = type;

      final res = await _dio.get('/api/sustainability', queryParameters: queryParams);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Get a single sustainability initiative by ID
  Future<Map<String, dynamic>> getInitiative(int id) async {
    try {
      final res = await _dio.get('/api/sustainability/$id');
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
