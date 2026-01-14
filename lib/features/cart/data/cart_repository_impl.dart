import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/cart.dart';
import 'cart_api.dart';
import 'cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._api);

  final CartApi _api;

  @override
  Future<Cart> getCart() => _api.getCart();

  @override
  Future<Cart> addItem({
    required int productId,
    required int quantity,
    required String selectedSize,
    String processingTimeType = 'normal',
  }) {
    return _api.addItem(
      productId: productId,
      quantity: quantity,
      selectedSize: selectedSize,
      processingTimeType: processingTimeType,
    );
  }

  @override
  Future<Cart> updateItemQuantity({required int cartItemId, required int quantity}) => _api.updateItemQuantity(cartItemId: cartItemId, quantity: quantity);

  @override
  Future<Cart> removeItem({required int cartItemId}) => _api.removeItem(cartItemId: cartItemId);

  @override
  Future<void> clearCart() => _api.clearCart();
}

final cartApiProvider = Provider<CartApi>((ref) {
  return CartApi(ref.watch(laravelDioProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartApiProvider));
});
