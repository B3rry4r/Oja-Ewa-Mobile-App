import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';

class BusinessSearchApi {
  BusinessSearchApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> search({
    required String q,
    String? categorySlug,
    String? state,
    String? city,
    String? sort,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final res = await _dio.get(
        '/api/business/public/search',
        queryParameters: {
          'q': q,
          'page': page,
          'per_page': perPage,
          if (categorySlug != null && categorySlug.isNotEmpty) 'category_slug': categorySlug,
          if (state != null && state.isNotEmpty) 'state': state,
          if (city != null && city.isNotEmpty) 'city': city,
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
