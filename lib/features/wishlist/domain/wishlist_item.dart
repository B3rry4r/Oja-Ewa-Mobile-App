import 'package:flutter/foundation.dart';

enum WishlistableType {
  product,
  businessProfile,
}

@immutable
class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.wishlistableId,
    required this.type,
    required this.title,
    this.imageUrl,
    this.price,
  });

  final int id;
  final int wishlistableId;
  final WishlistableType type;
  final String title;
  final String? imageUrl;
  final num? price;

  /// Used by API request bodies.
  String get apiType => switch (type) {
        WishlistableType.product => 'product',
        WishlistableType.businessProfile => 'business_profile',
      };

  static WishlistItem fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final wishlistableId = (json['wishlistable_id'] as num?)?.toInt() ?? 0;

    // API returns either a short type or a full class name.
    final rawType = (json['wishlistable_type'] as String?) ?? '';
    final type = rawType.contains('BusinessProfile') || rawType == 'business_profile'
        ? WishlistableType.businessProfile
        : WishlistableType.product;

    final wishlistable = json['wishlistable'];

    String title = '';
    String? image;
    num? price;

    if (wishlistable is Map<String, dynamic>) {
      title = (wishlistable['name'] as String?) ?? (wishlistable['business_name'] as String?) ?? '';
      image = (wishlistable['image'] as String?) ?? (wishlistable['business_logo'] as String?);
      final p = wishlistable['price'];
      if (p is num) price = p;
    }

    return WishlistItem(
      id: id,
      wishlistableId: wishlistableId,
      type: type,
      title: title,
      imageUrl: image,
      price: price,
    );
  }
}
