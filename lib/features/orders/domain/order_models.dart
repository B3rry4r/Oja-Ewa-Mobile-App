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
    required this.canRequestReturn,
    required this.returnDeadlineAt,
    required this.returnRequest,
  });

  final int id;
  final int sellerProfileId;
  final String? provider;
  final String? serviceName;
  final String? status;
  final String? trackingNumber;
  final num? shippingFee;
  final bool canRequestReturn;
  final DateTime? returnDeadlineAt;
  final ShipmentReturnRequestSummary? returnRequest;

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
      canRequestReturn: json['can_request_return'] == true,
      returnDeadlineAt: DateTime.tryParse(
        (json['return_deadline_at'] as String?) ?? '',
      ),
      returnRequest: json['return_request'] is Map<String, dynamic>
          ? ShipmentReturnRequestSummary.fromJson(
              json['return_request'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

@immutable
class ShipmentReturnRequestSummary {
  const ShipmentReturnRequestSummary({
    required this.id,
    required this.status,
    required this.reason,
    required this.rejectionReason,
    required this.requestedAt,
    required this.returnDeadlineAt,
    required this.reviewedAt,
    required this.approvedAt,
    required this.rejectedAt,
    required this.buyerReturnCarrier,
    required this.buyerReturnTrackingNumber,
    required this.buyerReturnShippedAt,
    required this.shipbubbleReturnLabelUrl,
    required this.refundedAt,
    required this.refundReference,
  });

  final int id;
  final String? status;
  final String? reason;
  final String? rejectionReason;
  final DateTime? requestedAt;
  final DateTime? returnDeadlineAt;
  final DateTime? reviewedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? buyerReturnCarrier;
  final String? buyerReturnTrackingNumber;
  final DateTime? buyerReturnShippedAt;
  final String? shipbubbleReturnLabelUrl;
  final DateTime? refundedAt;
  final String? refundReference;

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static ShipmentReturnRequestSummary fromJson(Map<String, dynamic> json) {
    return ShipmentReturnRequestSummary(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      status: json['status'] as String?,
      reason: json['reason'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      requestedAt: DateTime.tryParse((json['requested_at'] as String?) ?? ''),
      returnDeadlineAt: DateTime.tryParse(
        (json['return_deadline_at'] as String?) ?? '',
      ),
      reviewedAt: DateTime.tryParse((json['reviewed_at'] as String?) ?? ''),
      approvedAt: DateTime.tryParse((json['approved_at'] as String?) ?? ''),
      rejectedAt: DateTime.tryParse((json['rejected_at'] as String?) ?? ''),
      buyerReturnCarrier: json['buyer_return_carrier'] as String?,
      buyerReturnTrackingNumber:
          json['buyer_return_tracking_number'] as String?,
      buyerReturnShippedAt: DateTime.tryParse(
        (json['buyer_return_shipped_at'] as String?) ?? '',
      ),
      shipbubbleReturnLabelUrl: json['shipbubble_return_label_url'] as String?,
      refundedAt: DateTime.tryParse((json['refunded_at'] as String?) ?? ''),
      refundReference: json['refund_reference'] as String?,
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
    this.shippingName,
    this.shippingPhone,
    this.shippingCity,
    this.shippingState,
    this.shippingCountry,
    this.currency = 'NGN',
    this.exchangeRate,
    this.originalAmountNgn,
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
  // Shipping details (individual fields for display in order detail screen)
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;

  /// ISO 4217 currency code for this order. Defaults to NGN for legacy orders.
  final String currency;

  /// The live FX rate used at order creation (NGN per 1 unit of order currency).
  /// e.g. for GBP: 2050 means ₦2,050 = £1. Null for NGN orders.
  final num? exchangeRate;

  /// The original NGN total before FX conversion. Used for accounting/display.
  final num? originalAmountNgn;

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
      shippingName: json['shipping_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingState: json['shipping_state'] as String?,
      shippingCountry: json['shipping_country'] as String?,
      currency: (json['currency'] as String?)?.toUpperCase() ?? 'NGN',
      exchangeRate: json['exchange_rate'] as num?,
      originalAmountNgn: json['original_amount_ngn'] as num?,
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
      paymentUrl:
          (payload['payment_url'] as String?) ??
          (payload['link'] as String?) ??
          '',
      accessCode: (payload['access_code'] as String?) ?? '',
      reference:
          (payload['reference'] as String?) ??
          (payload['tx_ref'] as String?) ??
          '',
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
