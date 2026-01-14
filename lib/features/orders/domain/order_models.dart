import 'package:flutter/foundation.dart';

@immutable
class OrderItemProductSnapshot {
  const OrderItemProductSnapshot({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.sellerBusinessName,
  });

  final int id;
  final String name;
  final String? image;
  final num? price;
  final String? sellerBusinessName;

  static OrderItemProductSnapshot fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profile'];
    return OrderItemProductSnapshot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      image: json['image'] as String?,
      price: json['price'] as num?,
      sellerBusinessName: seller is Map<String, dynamic> ? seller['business_name'] as String? : null,
    );
  }
}

@immutable
class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.product,
  });

  final int id;
  final int productId;
  final int quantity;
  final num? unitPrice;
  final OrderItemProductSnapshot product;

  static OrderItem fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: json['unit_price'] as num?,
      product: OrderItemProductSnapshot.fromJson((json['product'] as Map?)?.cast<String, dynamic>() ?? const {}),
    );
  }
}

@immutable
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.paymentReference,
    required this.trackingNumber,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final num? totalPrice;
  final String? status;
  final String? paymentReference;
  final String? trackingNumber;
  final DateTime? createdAt;
  final List<OrderItem> items;

  static OrderSummary fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'];
    return OrderSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      totalPrice: json['total_price'] as num?,
      status: json['status'] as String?,
      paymentReference: json['payment_reference'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
      items: (rawItems is List) ? rawItems.whereType<Map<String, dynamic>>().map(OrderItem.fromJson).toList() : const [],
    );
  }
}

@immutable
class PaymentLink {
  const PaymentLink({
    required this.paymentUrl,
    required this.accessCode,
    required this.reference,
    required this.amount,
    required this.currency,
  });

  final String paymentUrl;
  final String accessCode;
  final String reference;
  final num amount;
  final String currency;

  static PaymentLink fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;
    return PaymentLink(
      paymentUrl: (payload['payment_url'] as String?) ?? '',
      accessCode: (payload['access_code'] as String?) ?? '',
      reference: (payload['reference'] as String?) ?? '',
      amount: (payload['amount'] as num?) ?? 0,
      currency: (payload['currency'] as String?) ?? 'NGN',
    );
  }
}

@immutable
class PaymentVerifyResult {
  const PaymentVerifyResult({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paidAt,
  });

  final int orderId;
  final String status;
  final num amount;
  final String currency;
  final DateTime? paidAt;

  static PaymentVerifyResult fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;
    return PaymentVerifyResult(
      orderId: (payload['order_id'] as num?)?.toInt() ?? 0,
      status: (payload['payment_status'] as String?) ?? '',
      amount: (payload['amount'] as num?) ?? 0,
      currency: (payload['currency'] as String?) ?? 'NGN',
      paidAt: DateTime.tryParse((payload['paid_at'] as String?) ?? ''),
    );
  }
}
