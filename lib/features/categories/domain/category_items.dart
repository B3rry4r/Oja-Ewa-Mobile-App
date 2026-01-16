import 'package:flutter/foundation.dart';

@immutable
sealed class CategoryItem {
  const CategoryItem();

  /// Unique identifier for the item (product id, business id, or initiative id)
  int get id;

  String get kind;
}

@immutable
class CategoryProductItem extends CategoryItem {
  const CategoryProductItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.avgRating,
  });

  @override
  final int id;
  final String name;
  final String? image;
  final String? price;
  final num? avgRating;

  @override
  String get kind => 'product';

  static CategoryProductItem fromJson(Map<String, dynamic> json) {
    return CategoryProductItem(
      id: (json['id'] as num?)?.toInt() ?? (json['product_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? (json['title'] as String?) ?? '',
      image: json['image'] as String? ?? json['image_url'] as String?,
      price: json['price']?.toString(),
      avgRating: json['avg_rating'] as num?,
    );
  }
}

@immutable
class CategoryBusinessItem extends CategoryItem {
  const CategoryBusinessItem({
    required this.id,
    required this.businessName,
    required this.category,
    required this.offeringType,
    required this.businessLogo,
    required this.city,
    required this.state,
    required this.storeStatus,
  });

  @override
  final int id;
  final String businessName;
  final String category;
  final String? offeringType;
  final String? businessLogo;
  final String? city;
  final String? state;
  final String? storeStatus;

  @override
  String get kind => 'business_profile';

  static CategoryBusinessItem fromJson(Map<String, dynamic> json) {
    return CategoryBusinessItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      businessName: (json['business_name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      offeringType: json['offering_type'] as String?,
      businessLogo: json['business_logo'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      storeStatus: json['store_status'] as String?,
    );
  }
}

@immutable
class CategoryInitiativeItem extends CategoryItem {
  const CategoryInitiativeItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.status,
  });

  @override
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? status;

  @override
  String get kind => 'initiative';

  static CategoryInitiativeItem fromJson(Map<String, dynamic> json) {
    return CategoryInitiativeItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String?,
    );
  }
}

CategoryItem parseCategoryItem(String type, Map<String, dynamic> json) {
  // For product listing types, always treat items as products.
  const productTypes = {
    'textiles',
    'shoes_bags',
    'afro_beauty_products',
    'art',
  };
  if (productTypes.contains(type)) {
    return CategoryProductItem.fromJson(json);
  }

  // Infer item type by payload shape (more robust than relying on the listing type).
  if (json.containsKey('business_name') || json.containsKey('business_logo')) {
    return CategoryBusinessItem.fromJson(json);
  }
  if (json.containsKey('title') && json.containsKey('description')) {
    return CategoryInitiativeItem.fromJson(json);
  }
  // Default to product.
  return CategoryProductItem.fromJson(json);
}
