import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/logistics_models.dart';
import '../domain/order_models.dart';

class OrdersApi {
  OrdersApi(this._dio);

  final Dio _dio;

  Future<List<OrderSummary>> listOrders({int page = 1}) async {
    try {
      final res = await _dio.get(
        '/api/orders',
        queryParameters: {'page': page},
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      final list = data['data'];
      if (list is! List) {
        return const [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(OrderSummary.fromJson)
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Create a new order with items and shipping details
  ///
  /// Required shipping fields:
  /// - shipping_name, shipping_phone, shipping_address
  /// - shipping_city, shipping_state, shipping_country
  Future<OrderSummary> createOrder({
    required List<Map<String, dynamic>> items,
    int? addressId,
    String? shippingName,
    String? shippingPhone,
    String? shippingAddress,
    String? shippingCity,
    String? shippingState,
    String? shippingCountry,
    String? shippingZipCode,
    required List<SelectedShippingQuote> selectedQuotes,
  }) async {
    try {
      final payload = <String, dynamic>{
        'items': items,
        'selected_quotes': selectedQuotes
            .map((quote) => quote.toJson())
            .toList(),
      };
      if (addressId != null) {
        payload['address_id'] = addressId;
      } else {
        payload.addAll({
          'shipping_name': shippingName,
          'shipping_phone': shippingPhone,
          'shipping_address': shippingAddress,
          'shipping_city': shippingCity,
          'shipping_state': shippingState,
          'shipping_country': shippingCountry,
          'shipping_zip_code': shippingZipCode,
        });
      }
      final res = await _dio.post('/api/orders', data: payload);
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      final order = data['order'];
      if (order is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return OrderSummary.fromJson(order);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(int id) async {
    try {
      final res = await _dio.get('/api/orders/$id');
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return data;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderTracking(int id) async {
    try {
      final res = await _dio.get('/api/orders/$id/tracking');
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return data;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> cancelOrder({required int id, required String reason}) async {
    try {
      await _dio.post(
        '/api/orders/$id/cancel',
        data: {'cancellation_reason': reason},
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
