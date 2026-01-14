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
        // Public browsing responses are typically wrapped: { status, data: { ...product... } }
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return inner;

        // Some endpoints may use { product: { ... } }
        final product = data['product'];
        if (product is Map<String, dynamic>) return product;

        // Fallback: assume already a product map.
        return data;
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
