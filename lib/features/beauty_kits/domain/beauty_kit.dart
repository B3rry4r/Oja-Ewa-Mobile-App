import 'package:flutter/foundation.dart';

/// Seller behind a kit item's product (subset of seller_profile fields the
/// beauty-kits API returns).
@immutable
class BeautyKitSeller {
  const BeautyKitSeller({
    required this.id,
    required this.businessName,
    this.city,
    this.state,
    this.badge,
  });

  final int? id;
  final String? businessName;
  final String? city;
  final String? state;
  final String? badge;

  static BeautyKitSeller? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return BeautyKitSeller(
      id: _parseNum(json['id'])?.toInt(),
      businessName: json['business_name'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      badge: json['badge'] as String?,
    );
  }
}

/// A single product inside a beauty kit (with its seller, price, image).
@immutable
class BeautyKitItem {
  const BeautyKitItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.seller,
  });

  final int id;
  final int productId;
  final int quantity;
  final String productName;
  final String? productImage;
  final num? productPrice;
  final BeautyKitSeller? seller;

  String? get sellerName => seller?.businessName;

  static BeautyKitItem fromJson(Map<String, dynamic> json) {
    final product = (json['product'] as Map?)?.cast<String, dynamic>();
    return BeautyKitItem(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      productId: _parseNum(json['product_id'])?.toInt() ?? 0,
      quantity: _parseNum(json['quantity'])?.toInt() ?? 1,
      productName: (product?['name'] as String?) ?? '',
      productImage: product?['image'] as String?,
      productPrice: _parseNum(product?['price']),
      seller: BeautyKitSeller.fromJson(
        (product?['seller_profile'] as Map?)?.cast<String, dynamic>(),
      ),
    );
  }
}

/// An admin-curated bundle of beauty products ("buy all in one").
@immutable
class BeautyKit {
  const BeautyKit({
    required this.id,
    required this.uuid,
    required this.slug,
    required this.name,
    required this.image,
    required this.items,
    this.description,
    this.category,
    this.totalPrice,
    this.itemsCount,
  });

  final int id;
  final String? uuid;
  final String slug;
  final String name;
  final String? image;
  final String? description;
  final String? category;
  final List<BeautyKitItem> items;

  /// Sum of (product price * quantity). Provided directly by detail responses;
  /// for list responses we fall back to summing loaded items.
  final num? totalPrice;
  final int? itemsCount;

  /// Best-effort total price even when the server didn't append it (lists).
  num get effectiveTotalPrice {
    if (totalPrice != null) return totalPrice!;
    return items.fold<num>(
      0,
      (sum, item) => sum + ((item.productPrice ?? 0) * item.quantity),
    );
  }

  int get effectiveItemsCount {
    if (itemsCount != null) return itemsCount!;
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Unique seller count across kit items (for "from N sellers" copy).
  int get sellerCount =>
      items.map((i) => i.seller?.id).where((id) => id != null).toSet().length;

  static BeautyKit fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return BeautyKit(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      uuid: json['uuid'] as String?,
      slug: (json['slug'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      image: json['image'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      totalPrice: _parseNum(json['total_price']),
      itemsCount: _parseNum(json['items_count'])?.toInt(),
      items: (rawItems is List)
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(BeautyKitItem.fromJson)
                .toList()
          : const [],
    );
  }
}

num? _parseNum(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}
