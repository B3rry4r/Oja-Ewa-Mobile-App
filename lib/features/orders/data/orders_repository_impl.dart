import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/logistics_models.dart';
import '../domain/order_models.dart';
import 'logistics_api.dart';
import 'orders_api.dart';
import 'payments_api.dart';
import 'momo_api.dart';

class OrdersRepository {
  OrdersRepository(
    this._ordersApi,
    this._paymentsApi,
    this._momoApi,
    this._logisticsApi,
  );

  final OrdersApi _ordersApi;
  final PaymentsApi _paymentsApi;
  final MoMoApi _momoApi;
  final LogisticsApi _logisticsApi;

  Future<List<OrderSummary>> listOrders({int page = 1}) =>
      _ordersApi.listOrders(page: page);

  Future<List<SellerShippingQuotes>> getShippingQuotes(
    LogisticsQuoteRequest request,
  ) => _logisticsApi.getShippingQuotes(request);

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
  }) => _ordersApi.createOrder(
    items: items,
    addressId: addressId,
    shippingName: shippingName,
    shippingPhone: shippingPhone,
    shippingAddress: shippingAddress,
    shippingCity: shippingCity,
    shippingState: shippingState,
    shippingCountry: shippingCountry,
    shippingZipCode: shippingZipCode,
    selectedQuotes: selectedQuotes,
  );

  Future<Map<String, dynamic>> getOrderDetails(int id) =>
      _ordersApi.getOrderDetails(id);

  Future<Map<String, dynamic>> getOrderTracking(int id) =>
      _ordersApi.getOrderTracking(id);

  Future<void> cancelOrder({required int id, required String reason}) =>
      _ordersApi.cancelOrder(id: id, reason: reason);

  Future<PaymentLink> createOrderPaymentLink({required int orderId}) =>
      _paymentsApi.createOrderPaymentLink(orderId: orderId);

  Future<PaymentVerifyResult> verifyPayment({required String reference}) =>
      _paymentsApi.verify(reference: reference);

  // MoMo payment methods
  Future<MoMoPaymentInitResponse> initializeMoMoPayment({
    required int orderId,
    required String phone,
  }) => _momoApi.initializePayment(orderId: orderId, phone: phone);

  Future<MoMoPaymentStatusResponse> checkMoMoPaymentStatus({
    required String referenceId,
  }) => _momoApi.checkPaymentStatus(referenceId: referenceId);
}

final ordersApiProvider = Provider<OrdersApi>((ref) {
  return OrdersApi(ref.watch(laravelDioProvider));
});

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  return PaymentsApi(ref.watch(laravelDioProvider));
});

final momoApiProvider = Provider<MoMoApi>((ref) {
  return MoMoApi(ref.watch(laravelDioProvider));
});

final logisticsApiProvider = Provider<LogisticsApi>((ref) {
  return LogisticsApi(ref.watch(laravelDioProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(
    ref.watch(ordersApiProvider),
    ref.watch(paymentsApiProvider),
    ref.watch(momoApiProvider),
    ref.watch(logisticsApiProvider),
  );
});
