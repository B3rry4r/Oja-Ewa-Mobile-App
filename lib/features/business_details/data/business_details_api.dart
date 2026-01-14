import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';

class BusinessDetailsApi {
  BusinessDetailsApi(this._dio);

  final Dio _dio;

  /// Get a single business by ID
  Future<Map<String, dynamic>> getBusiness(int id) async {
    try {
      final res = await _dio.get('/api/business/$id');
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Browse public businesses with optional filters
  /// Supports: category (beauty, brand, school, music), offering_type, page, per_page
  Future<Map<String, dynamic>> browsePublicBusinesses({
    String? category,
    String? offeringType,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (category != null) queryParams['category'] = category;
      if (offeringType != null) queryParams['offering_type'] = offeringType;

      final res = await _dio.get('/api/business/public', queryParameters: queryParams);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Get a single public business by ID
  Future<Map<String, dynamic>> getPublicBusiness(int id) async {
    try {
      final res = await _dio.get('/api/business/public/$id');
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
