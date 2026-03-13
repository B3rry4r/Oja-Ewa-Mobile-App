import 'package:flutter/foundation.dart';

@immutable
class OrderItemProductSnapshot {
  const OrderItemProductSnapshot({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.sellerProfileId,
    required this.sellerBusinessName,
  });

  final int id;
  final String name;
  final String? image;
  final num? price;
  final int? sellerProfileId;
  final String? sellerBusinessName;

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static OrderItemProductSnapshot fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profile'];
    return OrderItemProductSnapshot(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      image: json['image'] as String?,
      price: _parseNum(json['price']),
      sellerProfileId: seller is Map<String, dynamic>
          ? _parseNum(seller['id'])?.toInt()
          : null,
      sellerBusinessName: seller is Map<String, dynamic>
          ? seller['business_name'] as String?
          : null,
    );
  }
}

@immutable
class ShipmentSummary {
  const ShipmentSummary({
    required this.id,
    required this.sellerProfileId,
    required this.provider,
    required this.serviceName,
    required this.status,
    required this.trackingNumber,
    required this.shippingFee,
  });

  final int id;
  final int sellerProfileId;
  final String? provider;
  final String? serviceName;
  final String? status;
  final String? trackingNumber;
  final num? shippingFee;

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static ShipmentSummary fromJson(Map<String, dynamic> json) {
    return ShipmentSummary(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      sellerProfileId:
          _parseNum(json['seller_profile_id'])?.toInt() ??
          _parseNum(json['seller_id'])?.toInt() ??
          0,
      provider: json['provider'] as String?,
      serviceName: json['service_name'] as String?,
      status: json['status'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      shippingFee: _parseNum(json['shipping_fee']),
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

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static OrderItem fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      productId: _parseNum(json['product_id'])?.toInt() ?? 0,
      quantity: _parseNum(json['quantity'])?.toInt() ?? 0,
      unitPrice: _parseNum(json['unit_price']),
      product: OrderItemProductSnapshot.fromJson(
        (json['product'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

@immutable
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.deliveryFee,
    required this.status,
    required this.paymentStatus,
    required this.paymentReference,
    required this.trackingNumber,
    required this.createdAt,
    required this.items,
    required this.shipments,
  });

  final int id;
  final String? orderNumber;
  final num? totalPrice;
  final num? deliveryFee;
  final String? status;
  final String? paymentStatus;
  final String? paymentReference;
  final String? trackingNumber;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final List<ShipmentSummary> shipments;

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static OrderSummary fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] ?? json['items'];
    final rawShipments = json['shipments'];
    return OrderSummary(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      orderNumber: json['order_number'] as String?,
      totalPrice: _parseNum(json['total_price']),
      deliveryFee: _parseNum(json['delivery_fee']),
      status: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentReference: json['payment_reference'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
      items: (rawItems is List)
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(OrderItem.fromJson)
                .toList()
          : const [],
      shipments: (rawShipments is List)
          ? rawShipments
                .whereType<Map<String, dynamic>>()
                .map(ShipmentSummary.fromJson)
                .toList()
          : const [],
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

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static PaymentLink fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;
    return PaymentLink(
      paymentUrl: (payload['payment_url'] as String?) ?? '',
      accessCode: (payload['access_code'] as String?) ?? '',
      reference: (payload['reference'] as String?) ?? '',
      amount: _parseNum(payload['amount']) ?? 0,
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

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static PaymentVerifyResult fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;
    return PaymentVerifyResult(
      orderId: _parseNum(payload['order_id'])?.toInt() ?? 0,
      status: (payload['payment_status'] as String?) ?? '',
      amount: _parseNum(payload['amount']) ?? 0,
      currency: (payload['currency'] as String?) ?? 'NGN',
      paidAt: DateTime.tryParse((payload['paid_at'] as String?) ?? ''),
    );
  }
}
