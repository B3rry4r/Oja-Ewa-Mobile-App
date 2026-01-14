import 'package:flutter/foundation.dart';

@immutable
class CartProductSnapshot {
  const CartProductSnapshot({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    required this.processingDays,
    required this.sellerBusinessName,
  });

  final int id;
  final String name;
  final String? image;
  final num? price;

  /// Backend may return a comma-separated string (e.g. "S, M, L, XL")
  final String? size;

  /// Backend product field in cart response.
  final int? processingDays;

  final String? sellerBusinessName;

  static CartProductSnapshot fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profile'];
    return CartProductSnapshot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      image: json['image'] as String?,
      price: json['price'] as num?,
      size: json['size'] as String?,
      processingDays: (json['processing_days'] as num?)?.toInt(),
      sellerBusinessName: seller is Map<String, dynamic> ? seller['business_name'] as String? : null,
    );
  }
}

@immutable
class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.selectedSize,
    required this.processingTimeType,
    required this.product,
  });

  final int id;
  final int productId;
  final int quantity;
  final num? unitPrice;
  final num? subtotal;

  /// New cart variant fields
  final String selectedSize;
  final String processingTimeType; // normal|express

  final CartProductSnapshot product;

  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: json['unit_price'] as num?,
      subtotal: json['subtotal'] as num?,
      selectedSize: (json['selected_size'] as String?) ?? '',
      processingTimeType: (json['processing_time_type'] as String?) ?? 'normal',
      product: CartProductSnapshot.fromJson((json['product'] as Map?)?.cast<String, dynamic>() ?? const {}),
    );
  }
}

@immutable
class Cart {
  const Cart({
    required this.cartId,
    required this.items,
    required this.total,
    required this.itemsCount,
  });

  final int cartId;
  final List<CartItem> items;
  final num total;
  final int itemsCount;

  static Cart fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;

    final itemsRaw = payload['items'];
    final items = (itemsRaw is List)
        ? itemsRaw.whereType<Map<String, dynamic>>().map(CartItem.fromJson).toList()
        : const <CartItem>[];

    return Cart(
      cartId: (payload['cart_id'] as num?)?.toInt() ?? 0,
      items: items,
      total: (payload['total'] as num?) ?? 0,
      itemsCount: (payload['items_count'] as num?)?.toInt() ?? 0,
    );
  }
}
