import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/logistics_models.dart';
import '../domain/order_models.dart';

/// A single page of orders plus the backend pagination meta needed to drive
/// infinite scroll / "load more".
class OrdersPage {
  const OrdersPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<OrderSummary> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}

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

  /// Like [listOrders] but preserves the pagination meta so callers can page
  /// through the full order history instead of only the first 10.
  ///
  /// The backend paginates 10/page. Meta fields may live at the top level of
  /// the response or nested under `meta` (Laravel resource collections), so we
  /// read from both.
  Future<OrdersPage> listOrdersPage({int page = 1}) async {
    try {
      final res = await _dio.get(
        '/api/orders',
        queryParameters: {'page': page},
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }

      final listRaw = data['data'];
      final items = (listRaw is List)
          ? listRaw
              .whereType<Map<String, dynamic>>()
              .map(OrderSummary.fromJson)
              .toList()
          : const <OrderSummary>[];

      final metaRaw = data['meta'];
      final meta = metaRaw is Map<String, dynamic>
          ? metaRaw
          : const <String, dynamic>{};

      int? readInt(dynamic v) =>
          (v is num) ? v.toInt() : (v is String ? int.tryParse(v) : null);

      final currentPage =
          readInt(data['current_page']) ?? readInt(meta['current_page']) ?? page;
      final total =
          readInt(data['total']) ?? readInt(meta['total']) ?? items.length;
      final perPage =
          readInt(data['per_page']) ?? readInt(meta['per_page']) ?? 10;
      final lastPage = readInt(data['last_page']) ??
          readInt(meta['last_page']) ??
          (perPage > 0 ? ((total + perPage - 1) ~/ perPage) : currentPage);

      return OrdersPage(
        items: items,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
      );
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

  Future<Map<String, dynamic>> requestReturn({
    required int orderId,
    required int shipmentId,
    required String reason,
  }) async {
    try {
      final res = await _dio.post(
        '/api/orders/$orderId/shipments/$shipmentId/returns',
        data: {'reason': reason},
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return data;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> shipReturnBack({
    required int orderId,
    required int shipmentId,
    required int returnRequestId,
  }) async {
    try {
      final res = await _dio.post(
        '/api/orders/$orderId/shipments/$shipmentId/returns/$returnRequestId/ship-back',
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return data;
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
