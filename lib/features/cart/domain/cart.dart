import 'package:flutter/foundation.dart';

@immutable
class CartProductSnapshot {
  const CartProductSnapshot({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    required this.sellerBusinessName,
  });

  final int id;
  final String name;
  final String? image;
  final num? price;
  final String? size;
  final String? sellerBusinessName;

  static CartProductSnapshot fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profile'];
    return CartProductSnapshot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      image: json['image'] as String?,
      price: json['price'] as num?,
      size: json['size'] as String?,
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
    required this.product,
  });

  final int id;
  final int productId;
  final int quantity;
  final num? unitPrice;
  final num? subtotal;
  final CartProductSnapshot product;

  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: json['unit_price'] as num?,
      subtotal: json['subtotal'] as num?,
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
