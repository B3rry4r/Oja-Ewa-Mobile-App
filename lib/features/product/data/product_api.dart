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
      
      // Response shape can be one of two formats:
      // Format 1: { status: "success", data: { data: [...products], ... } }
      // Format 2: { data: [...products], current_page, per_page, total }
      
      // Try Format 2 first (paginated response with direct data array)
      final directData = data['data'];
      if (directData is List) {
        debugPrint('ProductApi: Found products in data array (Format 2)');
        final products = directData.whereType<Map<String, dynamic>>().toList();
        debugPrint('ProductApi: Successfully parsed ${products.length} products');
        return products;
      }
      
      // Try Format 1 (nested data)
      if (directData is Map<String, dynamic>) {
        final nestedProducts = directData['data'];
        if (nestedProducts is List) {
          debugPrint('ProductApi: Found products in data.data array (Format 1)');
          final products = nestedProducts.whereType<Map<String, dynamic>>().toList();
          debugPrint('ProductApi: Successfully parsed ${products.length} products');
          return products;
        } else {
          debugPrint('ProductApi: data.data is not a List: ${nestedProducts.runtimeType}');
        }
      } else if (directData != null) {
        debugPrint('ProductApi: data is not a List or Map: ${directData.runtimeType}');
      } else {
        debugPrint('ProductApi: data field is null');
      }
      
      return [];
    } catch (e, st) {
      debugPrint('ProductApi: getSellerProducts error: $e');
      debugPrint('ProductApi: Stack trace: $st');
      rethrow;
    }
  }

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

        // If backend returns an error payload without data/product, surface it
        if (data['message'] != null) {
          throw FormatException(data['message'] as String);
        }

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
  /// Fields style, tribe, size, fabric_type are required for textiles & shoes_bags
  /// NOT required for afro_beauty_products and art.
  /// 
  /// Note: Image upload requires a separate endpoint. The current API accepts
  /// image as a URL string. TODO: Backend needs to add multipart file upload support.
  Future<Map<String, dynamic>> createProduct({
    required int categoryId,
    required String name,
    String? style,
    String? tribe,
    String? fabricType,
    required String description,
    String? imagePath, // Local file path - requires backend upload endpoint
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
      
      // TODO: Backend needs to support multipart file upload for images
      // For now, image upload is not supported - products will be created without images
      // and images need to be uploaded via a separate endpoint (like business profile does)

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

  /// Upload product image
  /// POST /api/products/{id}/upload
  /// 
  /// Uploads an image file for a product. Must be called after product creation.
  /// Accepts: jpg, jpeg, png, webp (max 5MB)
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

  /// Update an existing product
  /// PUT /api/products/{id}
  /// 
  /// Note: Image upload is done separately via uploadProductImage().
  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    int? categoryId,
    String? name,
    String? style,
    String? tribe,
    String? fabricType,
    String? description,
    String? imagePath, // Local file path - requires backend upload endpoint
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
      
      // TODO: Backend needs to support multipart file upload for images

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
