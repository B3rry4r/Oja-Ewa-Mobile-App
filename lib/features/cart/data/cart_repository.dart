import '../domain/cart.dart';

abstract interface class CartRepository {
  Future<Cart> getCart();

  Future<Cart> addItem({
    required int productId,
    required int quantity,
    required String selectedSize,
    String processingTimeType,
  });

  Future<Cart> updateItemQuantity({required int cartItemId, required int quantity});
  Future<Cart> updateItemSize({required int cartItemId, required String selectedSize});
  Future<Cart> removeItem({required int cartItemId});
  Future<void> clearCart();
}
