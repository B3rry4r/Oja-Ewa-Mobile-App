import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_repository_impl.dart';

@immutable
class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.avgRating,
    required this.sellerProfileId,
    required this.sellerBusinessName,
    required this.size,
    required this.processingTimeType,
    required this.processingDays,
    required this.suggestions,
  });

  final int id;
  final String name;
  final String? description;
  final String? image;
  final num? price;
  final num? avgRating;
  final int? sellerProfileId;
  final String? sellerBusinessName;
  final String? size;
  final String? processingTimeType;
  final int? processingDays;
  final List<Map<String, dynamic>> suggestions;

  static ProductDetails fromJson(Map<String, dynamic> json) {
    final seller = json['seller_profile'];
    final suggestionsRaw = json['suggestions'];

    num? parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    return ProductDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      price: parseNum(json['price']),
      avgRating: parseNum(json['avg_rating']),
      sellerProfileId: seller is Map<String, dynamic> ? (seller['id'] as num?)?.toInt() : (json['seller_profile_id'] as num?)?.toInt(),
      sellerBusinessName: seller is Map<String, dynamic> ? seller['business_name'] as String? : null,
      size: json['size'] as String?,
      processingTimeType: json['processing_time_type'] as String?,
      processingDays: (parseNum(json['processing_days']) as num?)?.toInt(),
      suggestions: (suggestionsRaw is List) ? suggestionsRaw.whereType<Map<String, dynamic>>().toList() : const [],
    );
  }
}

final productDetailsProvider = FutureProvider.family<ProductDetails, int>((ref, id) async {
  final json = await ref.watch(productRepositoryProvider).getProductDetails(id);
  return ProductDetails.fromJson(json);
});
