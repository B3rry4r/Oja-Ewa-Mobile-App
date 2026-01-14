import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/order_models.dart';

class OrdersApi {
  OrdersApi(this._dio);

  final Dio _dio;

  Future<List<OrderSummary>> listOrders({int page = 1}) async {
    try {
      final res = await _dio.get('/api/orders', queryParameters: {'page': page});
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      final list = data['data'];
      if (list is! List) return const [];
      return list.whereType<Map<String, dynamic>>().map(OrderSummary.fromJson).toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<OrderSummary> createOrder({required List<Map<String, dynamic>> items}) async {
    try {
      final res = await _dio.post('/api/orders', data: {'items': items});
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      final order = data['order'];
      if (order is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return OrderSummary.fromJson(order);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(int id) async {
    try {
      final res = await _dio.get('/api/orders/$id');
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return data;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderTracking(int id) async {
    try {
      final res = await _dio.get('/api/orders/$id/tracking');
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return data;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> cancelOrder({required int id, required String reason}) async {
    try {
      await _dio.post('/api/orders/$id/cancel', data: {'cancellation_reason': reason});
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
