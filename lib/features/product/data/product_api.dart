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
        if (inner is Map<String, dynamic>) {
          // Common shape: { status, data: { product: {...}, suggestions: [...] } }
          final p = inner['product'];
          if (p is Map<String, dynamic>) {
            final merged = <String, dynamic>{...p};
            // merge sibling keys (e.g. suggestions)
            for (final entry in inner.entries) {
              if (entry.key == 'product') continue;
              merged[entry.key] = entry.value;
            }
            return merged;
          }
          // Sometimes inner is already the product map
          return inner;
        }

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
