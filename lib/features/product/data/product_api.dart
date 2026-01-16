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

  /// Create a new product (seller endpoint)
  /// POST /api/products
  /// 
  /// Fields style, tribe, size are required for textiles & shoes_bags
  /// fabric_type is required for textiles only
  /// NOT required for afro_beauty_products and art.
  Future<Map<String, dynamic>> createProduct({
    required int categoryId,
    required String name,
    String? style,
    String? tribe,
    String? fabricType,
    required String description,
    required String imagePath,
    List<String>? sizes,
    required String processingTimeType, // 'normal' or 'quick_quick'
    required int processingDays,
    required num price,
    int? discount,
  }) async {
    try {
      final map = <String, dynamic>{
        'category_id': categoryId,
        'name': name,
        'description': description,
        'image': await MultipartFile.fromFile(imagePath),
        'processing_time_type': processingTimeType,
        'processing_days': processingDays,
        'price': price,
      };
      
      // Only include extended fields if provided (textiles & shoes_bags)
      if (style != null) map['style'] = style;
      if (tribe != null) map['tribe'] = tribe;
      if (fabricType != null) map['fabric_type'] = fabricType;
      if (sizes != null && sizes.isNotEmpty) map['size'] = sizes.join(',');
      if (discount != null) map['discount'] = discount;
      
      final formData = FormData.fromMap(map);

      final res = await _dio.post('/api/products', data: formData);
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return inner;
        return data;
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Update an existing product
  /// PUT /api/products/{id}
  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    int? categoryId,
    String? name,
    String? style,
    String? tribe,
    String? fabricType,
    String? description,
    String? imagePath,
    List<String>? sizes,
    String? processingTimeType,
    int? processingDays,
    num? price,
    int? discount,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (categoryId != null) map['category_id'] = categoryId;
      if (name != null) map['name'] = name;
      if (style != null) map['style'] = style;
      if (tribe != null) map['tribe'] = tribe;
      if (fabricType != null) map['fabric_type'] = fabricType;
      if (description != null) map['description'] = description;
      if (sizes != null) map['size'] = sizes.join(',');
      if (processingTimeType != null) map['processing_time_type'] = processingTimeType;
      if (processingDays != null) map['processing_days'] = processingDays;
      if (price != null) map['price'] = price;
      if (discount != null) map['discount'] = discount;

      FormData formData;
      if (imagePath != null) {
        map['image'] = await MultipartFile.fromFile(imagePath);
        formData = FormData.fromMap(map);
      } else {
        formData = FormData.fromMap(map);
      }

      final res = await _dio.put('/api/products/$productId', data: formData);
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return inner;
        return data;
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Delete a product
  /// DELETE /api/products/{id}
  Future<void> deleteProduct(int productId) async {
    try {
      await _dio.delete('/api/products/$productId');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
