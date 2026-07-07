import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/cart/data/cart_repository_impl.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';
import '../../data/orders_api.dart';
import '../../data/orders_repository_impl.dart';
import '../../domain/logistics_models.dart';
import '../../domain/order_models.dart';

final ordersProvider = FutureProvider<OrdersPage>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) {
    return const OrdersPage(items: [], currentPage: 1, lastPage: 1, total: 0);
  }

  return ref.read(ordersApiProvider).listOrdersPage(page: 1);
});

/// Paginated, real-time order list state for the buyer's "Your Orders" screen.
@immutable
class OrdersListState {
  const OrdersListState({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
  });

  final List<OrderSummary> orders;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  bool get hasMore => currentPage < lastPage;

  OrdersListState copyWith({
    List<OrderSummary>? orders,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return OrdersListState(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  static const empty =
      OrdersListState(orders: [], currentPage: 1, lastPage: 1);
}

/// Holds live order status overrides from real-time events.
class OrderStatusOverridesController extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() => {};

  void setStatus(int orderId, String status) {
    state = {...state, orderId: status};
  }
}

final orderStatusOverridesProvider =
    NotifierProvider<OrderStatusOverridesController, Map<int, String>>(
      OrderStatusOverridesController.new,
    );

class OrdersRealtimeController extends AsyncNotifier<OrdersListState> {
  @override
  FutureOr<OrdersListState> build() {
    final async = ref.watch(ordersProvider);
    async.whenData((page) {
      state = AsyncData(
        OrdersListState(
          orders: page.items,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
        ),
      );
    });
    final page = async.value;
    return page == null
        ? OrdersListState.empty
        : OrdersListState(
            orders: page.items,
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          );
  }

  /// Fetch the next page of orders and append it to the current list.
  ///
  /// Mirrors the pagination pattern used elsewhere (e.g. category listing):
  /// no-op while already loading or when the last page has been reached.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final page = await ref.read(ordersApiProvider).listOrdersPage(
            page: nextPage,
          );
      state = AsyncData(
        current.copyWith(
          orders: [...current.orders, ...page.items],
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      // Keep the already-loaded orders, just stop the spinner.
      state = AsyncData(current.copyWith(isLoadingMore: false));
      debugPrint('OrdersRealtimeController.loadMore error: $e\n$st');
    }
  }

  void applyStatusUpdate(int orderId, String status) {
    final current = state.value;
    if (current == null) return;
    final updated = current.orders
        .map(
          (order) => order.id == orderId
              ? OrderSummary(
                  id: order.id,
                  orderNumber: order.orderNumber,
                  totalPrice: order.totalPrice,
                  deliveryFee: order.deliveryFee,
                  status: status,
                  paymentStatus: order.paymentStatus,
                  paymentReference: order.paymentReference,
                  trackingNumber: order.trackingNumber,
                  createdAt: order.createdAt,
                  items: order.items,
                  shipments: order.shipments,
                )
              : order,
        )
        .toList();
    state = AsyncData(current.copyWith(orders: updated));
    ref.read(orderStatusOverridesProvider.notifier).setStatus(orderId, status);
  }
}

final ordersRealtimeProvider =
    AsyncNotifierProvider<OrdersRealtimeController, OrdersListState>(
      OrdersRealtimeController.new,
    );

final orderDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  orderId,
) async {
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
    state = const AsyncLoading();
    try {
      final order = await ref
          .read(ordersRepositoryProvider)
          .createOrder(
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
      final link = await ref
          .read(ordersRepositoryProvider)
          .createOrderPaymentLink(orderId: order.id);
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

  Future<PaymentVerifyResult> verifyPayment({required String reference, String? transactionId}) async {
    state = const AsyncLoading();
    try {
      final res = await ref
          .read(ordersRepositoryProvider)
          .verifyPayment(reference: reference, transactionId: transactionId);
      state = const AsyncData(null);
      ref.invalidate(ordersProvider);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Re-add a past order's items to the cart, mirroring WAWUBasket's reorder.
  ///
  /// The backend has no dedicated reorder endpoint, so we replay each line
  /// through the existing cart add-item API (one product per item), then sync
  /// the shared cart state. Returns the number of items (re)added.
  Future<int> reorder(int orderId) async {
    state = const AsyncLoading();
    try {
      final detail =
          await ref.read(ordersRepositoryProvider).getOrderDetails(orderId);
      final orderData = (detail['data'] is Map<String, dynamic>)
          ? detail['data'] as Map<String, dynamic>
          : detail;
      final order = OrderSummary.fromJson(orderData);

      final cartRepo = ref.read(cartRepositoryProvider);
      var added = 0;
      for (final item in order.items) {
        if (item.productId <= 0) continue;
        await cartRepo.addItem(
          productId: item.productId,
          quantity: item.quantity > 0 ? item.quantity : 1,
          // Order items don't carry a size; backend treats '' as the default
          // line (same as a fresh add with no size selected).
          selectedSize: '',
        );
        added++;
      }

      // Sync the shared cart so the badge + cart screen reflect the new items.
      ref.read(optimisticCartProvider.notifier).requestSync();
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
      return added;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Cancel an order the buyer no longer wants.
  ///
  /// The backend only allows cancelling pending/paid/processing orders (else
  /// 400); the UI should already gate the action on a cancellable status.
  Future<void> cancelOrder({
    required int orderId,
    required String reason,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(ordersRepositoryProvider)
          .cancelOrder(id: orderId, reason: reason);
      state = const AsyncData(null);
      ref.invalidate(orderDetailsProvider(orderId));
      ref.invalidate(ordersProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> requestReturn({
    required int orderId,
    required int shipmentId,
    required String reason,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(ordersRepositoryProvider)
          .requestReturn(
            orderId: orderId,
            shipmentId: shipmentId,
            reason: reason,
          );
      state = const AsyncData(null);
      ref.invalidate(orderDetailsProvider(orderId));
      ref.invalidate(ordersProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> shipReturnBack({
    required int orderId,
    required int shipmentId,
    required int returnRequestId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(ordersRepositoryProvider).shipReturnBack(
        orderId: orderId,
        shipmentId: shipmentId,
        returnRequestId: returnRequestId,
      );
      state = const AsyncData(null);
      ref.invalidate(orderDetailsProvider(orderId));
      ref.invalidate(ordersProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final orderActionsProvider =
    AsyncNotifierProvider<OrderActionsController, void>(
      OrderActionsController.new,
    );
