import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';

class ProductApi {
  ProductApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getProductDetails(int id) async {
    try {
      // Public endpoint for browsing products
      final res = await _dio.get('/api/products/public/$id');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        // This endpoint returns the product object directly (not wrapped in {data:...}) per docs.
        return data;
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
