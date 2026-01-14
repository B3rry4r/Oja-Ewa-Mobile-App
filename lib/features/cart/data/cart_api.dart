import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/cart.dart';

class CartApi {
  CartApi(this._dio);

  final Dio _dio;

  Future<Cart> getCart() async {
    try {
      final res = await _dio.get('/api/cart');
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return Cart.fromWrappedResponse(data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Cart> addItem({
    required int productId,
    required int quantity,
    required String selectedSize,
    String processingTimeType = 'normal',
  }) async {
    try {
      await _dio.post(
        '/api/cart/items',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'selected_size': selectedSize,
          'processing_time_type': processingTimeType,
        },
      );
      // To keep it simple and consistent, just fetch the cart.
      return getCart();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Cart> updateItemQuantity({required int cartItemId, required int quantity}) async {
    try {
      await _dio.patch('/api/cart/items/$cartItemId', data: {'quantity': quantity});
      return getCart();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Cart> removeItem({required int cartItemId}) async {
    try {
      await _dio.delete('/api/cart/items/$cartItemId');
      return getCart();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/api/cart');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
