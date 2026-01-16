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

  List<Map<String, dynamic>> normalize(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      final orders = raw['orders'];
      if (orders is List) {
        return orders.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  final data = response['data'];
  final items = normalize(data);
  if (items.isNotEmpty) {
    return items.map(SellerOrder.fromJson).toList();
  }

  final fallback = normalize(response);
  return fallback.map(SellerOrder.fromJson).toList();
});

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
    final itemsList = json['items'] as List? ?? json['order_items'] as List? ?? [];
    final customer = json['customer'] as Map<String, dynamic>?;
    
    return SellerOrder(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? json['id'].toString(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      customerName: json['customer_name'] as String? ?? customer?['name'] as String? ?? json['shipping_name'] as String?,
      customerPhone: json['customer_phone'] as String? ?? customer?['phone'] as String? ?? json['shipping_phone'] as String?,
      shippingAddress: (customer != null || json['shipping_address'] != null || json['shipping_city'] != null)
          ? ShippingAddress.fromJson(json)
          : null,
      items: itemsList.map((e) => SellerOrderItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
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
    
    return SellerOrderItem(
      productId: json['product_id'] as int? ?? product?['id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? product?['name'] as String? ?? 'Unknown Product',
      productImage: json['product_image'] as String? ?? product?['image'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      size: json['size'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? (json['unit_price'] as num?)?.toDouble() ?? 0,
    );
  }
}
