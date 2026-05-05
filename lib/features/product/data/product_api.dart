import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/dio_error_mapper.dart';

class ProductApi {
  ProductApi(this._dio);

  final Dio _dio;

  /// Get seller's own products (authenticated seller only)
  /// GET /api/products
  Future<List<Map<String, dynamic>>> getSellerProducts({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      debugPrint('ProductApi: Fetching seller products (page=$page, perPage=$perPage)');
      
      final res = await _dio.get(
        '/api/products',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      
      debugPrint('ProductApi: Response received - status: ${res.statusCode}');
      
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        debugPrint('ProductApi: Unexpected response type: ${data.runtimeType}');
        return [];
      }
      
      debugPrint('ProductApi: Response keys: ${data.keys.toList()}');
      
      final directData = data['data'];
      if (directData is List) {
        debugPrint('ProductApi: Found products in data array (Format 2)');
        final products = directData.whereType<Map<String, dynamic>>().toList();
        return products;
      }
      
      if (directData is Map<String, dynamic>) {
        final nestedProducts = directData['data'];
        if (nestedProducts is List) {
          debugPrint('ProductApi: Found products in data.data array (Format 1)');
          final products = nestedProducts.whereType<Map<String, dynamic>>().toList();
          return products;
        }
      }
      
      return [];
    } catch (e, st) {
      debugPrint('ProductApi: getSellerProducts error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProductDetails(int id) async {
    try {
      final res = await _dio.get('/api/products/public/$id');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          final p = inner['product'];
          if (p is Map<String, dynamic>) {
            final merged = <String, dynamic>{...p};
            for (final entry in inner.entries) {
              if (entry.key == 'product') continue;
              merged[entry.key] = entry.value;
            }
            return merged;
          }
          return inner;
        }
        final product = data['product'];
        if (product is Map<String, dynamic>) return product;
        return data;
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> createProduct({
    required int categoryId,
    required String name,
    String? style,
    String? tribe,
    String? fabricType,
    required String description,
    String? imagePath,
    List<String>? sizes,
    required String processingTimeType,
    required int processingDays,
    required num price,
    int? discount,
    num? weightKg,
    num? lengthCm,
    num? widthCm,
    num? heightCm,
  }) async {
    try {
      final map = <String, dynamic>{
        'category_id': categoryId,
        'name': name,
        'description': description,
        'processing_time_type': processingTimeType,
        'processing_days': processingDays,
        'price': price,
      };
      
      if (style != null) map['style'] = style;
      if (tribe != null) map['tribe'] = tribe;
      if (fabricType != null) map['fabric_type'] = fabricType;
      if (sizes != null && sizes.isNotEmpty) map['size'] = sizes.join(',');
      if (discount != null) map['discount'] = discount;
      
      if (weightKg != null) map['weight_kg'] = weightKg;
      if (lengthCm != null) map['length_cm'] = lengthCm;
      if (widthCm != null) map['width_cm'] = widthCm;
      if (heightCm != null) map['height_cm'] = heightCm;

      final res = await _dio.post('/api/products', data: map);
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

  Future<String> uploadProductImage({
    required int productId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final res = await _dio.post('/api/products/$productId/upload', data: formData);
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final imageUrl = data['data']?['image_url'] as String?;
        if (imageUrl != null) return imageUrl;
      }
      throw const FormatException('Failed to get image URL from response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

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
    num? weightKg,
    num? lengthCm,
    num? widthCm,
    num? heightCm,
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
      
      if (weightKg != null) map['weight_kg'] = weightKg;
      if (lengthCm != null) map['length_cm'] = lengthCm;
      if (widthCm != null) map['width_cm'] = widthCm;
      if (heightCm != null) map['height_cm'] = heightCm;

      final res = await _dio.put('/api/products/$productId', data: map);
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

  Future<void> deleteProduct(int productId) async {
    try {
      await _dio.delete('/api/products/$productId');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
