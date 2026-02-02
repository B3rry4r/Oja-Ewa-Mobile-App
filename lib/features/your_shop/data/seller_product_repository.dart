import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/features/product/data/product_api.dart';
import 'package:ojaewa/features/product/data/product_repository_impl.dart';

final sellerProductRepositoryProvider = Provider<SellerProductRepository>((ref) {
  final api = ref.watch(productApiProvider);
  return SellerProductRepository(api);
});

class SellerProductRepository {
  SellerProductRepository(this._api);
  final ProductApi _api;

  /// Get all products for the authenticated seller
  /// Endpoint: GET /api/products (auth required)
  Future<List<Map<String, dynamic>>> getMyProducts({
    int page = 1,
    int perPage = 10,
  }) async {
    return _api.getSellerProducts(page: page, perPage: perPage);
  }

  /// Create a new product.
  /// 
  /// Fields style, tribe, sizes, fabric_type are required for textiles & shoes_bags
  /// NOT required for afro_beauty_products and art.
  /// 
  /// Note: Image upload requires backend support. Image path is stored for future upload.
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
  }) {
    return _api.createProduct(
      categoryId: categoryId,
      name: name,
      style: style,
      tribe: tribe,
      fabricType: fabricType,
      description: description,
      imagePath: imagePath,
      sizes: sizes,
      processingTimeType: processingTimeType,
      processingDays: processingDays,
      price: price,
      discount: discount,
    );
  }

  /// Upload product image after creation
  Future<String> uploadProductImage({
    required int productId,
    required String filePath,
  }) {
    return _api.uploadProductImage(productId: productId, filePath: filePath);
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
  }) {
    return _api.updateProduct(
      productId: productId,
      categoryId: categoryId,
      name: name,
      style: style,
      tribe: tribe,
      fabricType: fabricType,
      description: description,
      imagePath: imagePath,
      sizes: sizes,
      processingTimeType: processingTimeType,
      processingDays: processingDays,
      price: price,
      discount: discount,
    );
  }

  Future<void> deleteProduct(int productId) {
    return _api.deleteProduct(productId);
  }
}
