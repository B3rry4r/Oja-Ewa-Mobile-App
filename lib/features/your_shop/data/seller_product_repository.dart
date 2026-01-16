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

  Future<Map<String, dynamic>> createProduct({
    required int categoryId,
    required String name,
    required String gender,
    required String style,
    required String tribe,
    required String description,
    required String imagePath,
    required List<String> sizes,
    required String processingTimeType,
    required int processingDays,
    required num price,
    int? discount,
  }) {
    return _api.createProduct(
      categoryId: categoryId,
      name: name,
      gender: gender,
      style: style,
      tribe: tribe,
      description: description,
      imagePath: imagePath,
      sizes: sizes,
      processingTimeType: processingTimeType,
      processingDays: processingDays,
      price: price,
      discount: discount,
    );
  }

  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    int? categoryId,
    String? name,
    String? gender,
    String? style,
    String? tribe,
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
      gender: gender,
      style: style,
      tribe: tribe,
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
