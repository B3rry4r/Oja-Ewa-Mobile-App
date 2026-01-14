import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/product_filters.dart';

class ProductFiltersApi {
  ProductFiltersApi(this._dio);

  final Dio _dio;

  /// Fetch available filters from GET /api/products/filters
  /// This endpoint is public (no auth required)
  Future<ProductFilters> getFilters() async {
    try {
      final res = await _dio.get('/api/products/filters');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          return ProductFilters.fromJson(inner);
        }
        return ProductFilters.fromJson(data);
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
