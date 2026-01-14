import 'package:flutter/foundation.dart';

@immutable
class SearchProduct {
  const SearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.gender,
    required this.style,
    required this.tribe,
    required this.price,
    required this.image,
    required this.avgRating,
    required this.businessName,
  });

  final int id;
  final String name;
  final String? description;
  final String? gender;
  final String? style;
  final String? tribe;
  final num? price;
  final String? image;
  final num? avgRating;
  final String? businessName;

  static SearchProduct fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profile'];
    
    // Price can be string "250.00" or num - handle both
    num? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    return SearchProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      gender: json['gender'] as String?,
      style: json['style'] as String?,
      tribe: json['tribe'] as String?,
      price: parsePrice(json['price']),
      image: json['image'] as String?,
      avgRating: parsePrice(json['avg_rating']),
      businessName: seller is Map<String, dynamic> ? seller['business_name'] as String? : null,
    );
  }
}
