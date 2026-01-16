import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';

class SustainabilitySearchApi {
  SustainabilitySearchApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> search({
    required String q,
    String? categorySlug,
    String? sort,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final res = await _dio.get(
        '/api/sustainability/search',
        queryParameters: {
          'q': q,
          'page': page,
          'per_page': perPage,
          if (categorySlug != null && categorySlug.isNotEmpty) 'category_slug': categorySlug,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );
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
