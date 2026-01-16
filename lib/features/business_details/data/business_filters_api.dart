import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';

class BusinessFiltersApi {
  BusinessFiltersApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> getFilters() async {
    try {
      final res = await _dio.get('/api/business/public/filters');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : data;
      }
      return const {};
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
