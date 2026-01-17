import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';

/// API service for seller order management
class SellerOrdersApi {
  SellerOrdersApi(this._dio);

  final Dio _dio;

  /// GET /api/seller/orders - List orders for seller
  /// [status] - Filter by: pending, processing, shipped, delivered, cancelled
  /// [perPage] - Items per page (1-50, default: 10)
  Future<Map<String, dynamic>> listOrders({
    String? status,
    int? perPage,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null) queryParams['status'] = status;
      if (perPage != null) queryParams['per_page'] = perPage;

      final res = await _dio.get('/api/seller/orders', queryParameters: queryParams);
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is List) {
        return {'data': data};
      }
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /api/seller/orders/{orderId} - Get seller order details
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final res = await _dio.get('/api/seller/orders/$orderId');
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return data['data'] ?? data;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// PATCH /api/seller/orders/{orderId}/status - Update order status
  /// [status] - New status: processing, shipped, delivered, cancelled
  /// [trackingNumber] - Optional tracking number (recommended when shipping)
  /// [reason] - Optional reason (required for cancellation)
  Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
    String? trackingNumber,
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{'status': status};
      if (trackingNumber != null) body['tracking_number'] = trackingNumber;
      if (reason != null) body['reason'] = reason;

      final res = await _dio.patch('/api/seller/orders/$orderId/status', data: body);
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
