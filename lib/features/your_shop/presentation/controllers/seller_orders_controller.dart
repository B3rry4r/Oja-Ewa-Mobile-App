import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import '../../data/seller_orders_api.dart';

/// Provider for the seller orders API
final sellerOrdersApiProvider = Provider<SellerOrdersApi>((ref) {
  return SellerOrdersApi(ref.watch(laravelDioProvider));
});

/// Provider for listing seller orders with optional status filter
final sellerOrdersProvider = FutureProvider.autoDispose.family<List<SellerOrder>, String?>((ref, status) async {
  final api = ref.watch(sellerOrdersApiProvider);
  final response = await api.listOrders(status: status, perPage: 50);

  List<Map<String, dynamic>> extractOrders(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data != null) {
        return extractOrders(data);
      }
      final orders = raw['orders'];
      if (orders != null) {
        return extractOrders(orders);
      }
    }
    return const [];
  }

  final items = extractOrders(response);
  return items.map(SellerOrder.fromJson).toList();
});

class SellerOrdersRealtimeController extends AsyncNotifier<List<SellerOrder>> {
  SellerOrdersRealtimeController(this._status);

  final String? _status;

  @override
  FutureOr<List<SellerOrder>> build() {
    final async = ref.watch(sellerOrdersProvider(_status));
    async.whenData((data) {
      state = AsyncData(data);
    });
    return async.value ?? const [];
  }

  void applyNewOrder(SellerOrder order) {
    final current = state.value ?? const [];
    state = AsyncData([order, ...current]);
  }

  void applyStatusUpdate(int orderId, String statusValue) {
    final current = state.value ?? const [];
    final updated = current
        .map((order) => order.id == orderId
            ? SellerOrder(
                id: order.id,
                orderNumber: order.orderNumber,
                status: statusValue,
                createdAt: order.createdAt,
                customerName: order.customerName,
                customerPhone: order.customerPhone,
                shippingAddress: order.shippingAddress,
                items: order.items,
                totalPrice: order.totalPrice,
                trackingNumber: order.trackingNumber,
                shippedAt: order.shippedAt,
                deliveredAt: order.deliveredAt,
                cancellationReason: order.cancellationReason,
              )
            : order)
        .toList();
    state = AsyncData(updated);
  }
}

final sellerOrdersRealtimeProvider = AsyncNotifierProvider.family<SellerOrdersRealtimeController, List<SellerOrder>, String?>(
  SellerOrdersRealtimeController.new,
);

/// Provider for getting a single order's details
final sellerOrderDetailsProvider = FutureProvider.autoDispose.family<SellerOrder, int>((ref, orderId) async {
  final api = ref.watch(sellerOrdersApiProvider);
  final data = await api.getOrderDetails(orderId);
  return SellerOrder.fromJson(data);
});

/// Notifier for order actions (update status)
class SellerOrderActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Mark order as processing (accept order)
  Future<void> acceptOrder(int orderId) async {
    state = const AsyncLoading();
    try {
      await ref.read(sellerOrdersApiProvider).updateOrderStatus(
        orderId: orderId,
        status: 'processing',
      );
      state = const AsyncData(null);
      ref.invalidate(sellerOrdersProvider);
      ref.invalidate(sellerOrderDetailsProvider(orderId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Mark order as shipped with optional tracking number
  Future<void> shipOrder(int orderId, {String? trackingNumber}) async {
    state = const AsyncLoading();
    try {
      await ref.read(sellerOrdersApiProvider).updateOrderStatus(
        orderId: orderId,
        status: 'shipped',
        trackingNumber: trackingNumber,
      );
      state = const AsyncData(null);
      ref.invalidate(sellerOrdersProvider);
      ref.invalidate(sellerOrderDetailsProvider(orderId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Mark order as delivered
  Future<void> deliverOrder(int orderId) async {
    state = const AsyncLoading();
    try {
      await ref.read(sellerOrdersApiProvider).updateOrderStatus(
        orderId: orderId,
        status: 'delivered',
      );
      state = const AsyncData(null);
      ref.invalidate(sellerOrdersProvider);
      ref.invalidate(sellerOrderDetailsProvider(orderId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Cancel order with reason
  Future<void> cancelOrder(int orderId, String reason) async {
    state = const AsyncLoading();
    try {
      await ref.read(sellerOrdersApiProvider).updateOrderStatus(
        orderId: orderId,
        status: 'cancelled',
        reason: reason,
      );
      state = const AsyncData(null);
      ref.invalidate(sellerOrdersProvider);
      ref.invalidate(sellerOrderDetailsProvider(orderId));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final sellerOrderActionsProvider = NotifierProvider<SellerOrderActionsNotifier, AsyncValue<void>>(
  SellerOrderActionsNotifier.new,
);

/// Model for seller orders
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class SellerOrder {
  final int id;
  final String orderNumber;
  final String status;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;
  final ShippingAddress? shippingAddress;
  final List<SellerOrderItem> items;
  final double totalPrice;
  final String? trackingNumber;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;

  SellerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
    this.shippingAddress,
    required this.items,
    required this.totalPrice,
    this.trackingNumber,
    this.shippedAt,
    this.deliveredAt,
    this.cancellationReason,
  });

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] ?? json['order_items'];
    final List<Map<String, dynamic>> itemsList;
    if (itemsRaw is List) {
      itemsList = itemsRaw.whereType<Map<String, dynamic>>().toList();
    } else {
      itemsList = [];
    }
    final customer = json['customer'] as Map<String, dynamic>?;
    
    // Helper to parse int from various types
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    return SellerOrder(
      id: parseInt(json['id']) ?? 0,
      orderNumber: json['order_number'] as String? ?? json['id'].toString(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      customerName: json['customer_name'] as String? ?? customer?['name'] as String? ?? json['shipping_name'] as String?,
      customerPhone: json['customer_phone'] as String? ?? customer?['phone'] as String? ?? json['shipping_phone'] as String?,
      shippingAddress: (customer != null || json['shipping_address'] != null || json['shipping_city'] != null)
          ? ShippingAddress.fromJson(json)
          : null,
      items: itemsList.map((e) => SellerOrderItem.fromJson(e)).toList(),
      totalPrice: _parseDouble(json['total_price']) ?? 0,
      trackingNumber: json['tracking_number'] as String?,
      shippedAt: json['shipped_at'] != null ? DateTime.tryParse(json['shipped_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'] as String) : null,
      cancellationReason: json['cancellation_reason'] as String? ?? json['reason'] as String?,
    );
  }

  /// Check if order can be accepted (is pending)
  bool get canAccept => status == 'pending';
  
  /// Check if order can be shipped (is processing)
  bool get canShip => status == 'processing';
  
  /// Check if order can be marked delivered (is shipped)
  bool get canDeliver => status == 'shipped';
  
  /// Check if order can be cancelled
  bool get canCancel => status == 'pending' || status == 'processing';
}

class ShippingAddress {
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  ShippingAddress({this.address, this.city, this.state, this.country});

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['shipping_address'] as String? ?? json['address'] as String?,
      city: json['shipping_city'] as String? ?? json['city'] as String?,
      state: json['shipping_state'] as String? ?? json['state'] as String?,
      country: json['shipping_country'] as String? ?? json['country'] as String?,
    );
  }

  String get fullAddress {
    final parts = [address, city, state, country].where((e) => e != null && e.isNotEmpty);
    return parts.join(', ');
  }
}

class SellerOrderItem {
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final String? size;
  final double price;

  SellerOrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    this.size,
    required this.price,
  });

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    
    // Helper to parse int from various types
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    // Helper to parse double from various types
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }
    
    // Size can be String, int (for shoe sizes), or null
    String? parseSize(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is num) return value.toString();
      return null;
    }
    
    return SellerOrderItem(
      productId: parseInt(json['product_id']) ?? parseInt(product?['id']) ?? 0,
      productName: json['product_name'] as String? ?? product?['name'] as String? ?? 'Unknown Product',
      productImage: json['product_image'] as String? ?? product?['image'] as String?,
      quantity: parseInt(json['quantity']) ?? 1,
      size: parseSize(json['size']),
      price: parseDouble(json['price']) ?? parseDouble(json['unit_price']) ?? 0,
    );
  }
}
