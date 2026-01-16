import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/features/your_shop/data/seller_product_repository.dart';

/// State for product creation/update operations
final sellerProductActionsProvider = AsyncNotifierProvider<SellerProductActionsNotifier, void>(
  SellerProductActionsNotifier.new,
);

class SellerProductActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Create a new product.
  /// 
  /// Fields style, tribe, sizes are required for textiles & shoes_bags
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
    required String processingTimeType,
    required int processingDays,
    required num price,
    int? discount,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(sellerProductRepositoryProvider).createProduct(
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
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
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
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(sellerProductRepositoryProvider).updateProduct(
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
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    state = const AsyncLoading();
    try {
      await ref.read(sellerProductRepositoryProvider).deleteProduct(productId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
