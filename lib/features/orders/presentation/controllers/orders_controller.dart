import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import '../../data/orders_repository_impl.dart';
import '../../domain/order_models.dart';

final ordersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return const [];

  return ref.read(ordersRepositoryProvider).listOrders(page: 1);
});

/// Holds live order status overrides from real-time events.
class OrderStatusOverridesController extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() => {};

  void setStatus(int orderId, String status) {
    state = {...state, orderId: status};
  }
}

final orderStatusOverridesProvider = NotifierProvider<OrderStatusOverridesController, Map<int, String>>(
  OrderStatusOverridesController.new,
);

class OrdersRealtimeController extends AsyncNotifier<List<OrderSummary>> {
  @override
  FutureOr<List<OrderSummary>> build() {
    final async = ref.watch(ordersProvider);
    async.whenData((data) {
      state = AsyncData(data);
    });
    return async.value ?? const [];
  }

  void applyStatusUpdate(int orderId, String status) {
    final current = state.value ?? const [];
    final updated = current
        .map((order) => order.id == orderId
            ? OrderSummary(
                id: order.id,
                orderNumber: order.orderNumber,
                totalPrice: order.totalPrice,
                status: status,
                paymentReference: order.paymentReference,
                trackingNumber: order.trackingNumber,
                createdAt: order.createdAt,
                items: order.items,
              )
            : order)
        .toList();
    state = AsyncData(updated);
    ref.read(orderStatusOverridesProvider.notifier).setStatus(orderId, status);
  }
}

final ordersRealtimeProvider = AsyncNotifierProvider<OrdersRealtimeController, List<OrderSummary>>(
  OrdersRealtimeController.new,
);

final orderDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, orderId) async {
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return const {};

  return ref.read(ordersRepositoryProvider).getOrderDetails(orderId);
});

class OrderActionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<PaymentLink> createOrderAndPaymentLink({
    required List<Map<String, dynamic>> items,
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String shippingCity,
    required String shippingState,
    required String shippingCountry,
  }) async {
    state = const AsyncLoading();
    try {
      final order = await ref.read(ordersRepositoryProvider).createOrder(
        items: items,
        shippingName: shippingName,
        shippingPhone: shippingPhone,
        shippingAddress: shippingAddress,
        shippingCity: shippingCity,
        shippingState: shippingState,
        shippingCountry: shippingCountry,
      );
      final link = await ref.read(ordersRepositoryProvider).createOrderPaymentLink(orderId: order.id);
      // We intentionally do not clear cart automatically here; backend docs suggest clearing after successful order creation.
      // We can do it after payment verification.
      state = const AsyncData(null);
      ref.invalidate(ordersProvider);
      return link;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<PaymentVerifyResult> verifyPayment({required String reference}) async {
    state = const AsyncLoading();
    try {
      final res = await ref.read(ordersRepositoryProvider).verifyPayment(reference: reference);
      state = const AsyncData(null);
      ref.invalidate(ordersProvider);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final orderActionsProvider = AsyncNotifierProvider<OrderActionsController, void>(OrderActionsController.new);
