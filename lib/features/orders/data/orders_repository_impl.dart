import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/order_models.dart';
import 'orders_api.dart';
import 'payments_api.dart';

class OrdersRepository {
  OrdersRepository(this._ordersApi, this._paymentsApi);

  final OrdersApi _ordersApi;
  final PaymentsApi _paymentsApi;

  Future<List<OrderSummary>> listOrders({int page = 1}) => _ordersApi.listOrders(page: page);

  Future<OrderSummary> createOrder({required List<Map<String, dynamic>> items}) => _ordersApi.createOrder(items: items);

  Future<Map<String, dynamic>> getOrderDetails(int id) => _ordersApi.getOrderDetails(id);

  Future<Map<String, dynamic>> getOrderTracking(int id) => _ordersApi.getOrderTracking(id);

  Future<void> cancelOrder({required int id, required String reason}) => _ordersApi.cancelOrder(id: id, reason: reason);

  Future<PaymentLink> createOrderPaymentLink({required int orderId}) => _paymentsApi.createOrderPaymentLink(orderId: orderId);

  Future<PaymentVerifyResult> verifyPayment({required String reference}) => _paymentsApi.verify(reference: reference);
}

final ordersApiProvider = Provider<OrdersApi>((ref) {
  return OrdersApi(ref.watch(laravelDioProvider));
});

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  return PaymentsApi(ref.watch(laravelDioProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.watch(ordersApiProvider), ref.watch(paymentsApiProvider));
});
