import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';

class BusinessDetailsApi {
  BusinessDetailsApi(this._dio);

  final Dio _dio;

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
}
