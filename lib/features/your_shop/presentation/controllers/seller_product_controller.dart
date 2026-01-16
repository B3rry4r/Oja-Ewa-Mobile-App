import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/features/your_shop/data/seller_product_repository.dart';

/// State for product creation/update operations
final sellerProductActionsProvider = AsyncNotifierProvider<SellerProductActionsNotifier, void>(
  SellerProductActionsNotifier.new,
);

class SellerProductActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

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
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(sellerProductRepositoryProvider).createProduct(
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
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(sellerProductRepositoryProvider).updateProduct(
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
