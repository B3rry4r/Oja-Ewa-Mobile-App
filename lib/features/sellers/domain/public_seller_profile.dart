import 'package:flutter/foundation.dart';

@immutable
class PublicSellerProfile {
  const PublicSellerProfile({
    required this.id,
    required this.businessName,
    required this.businessLogo,
    required this.businessEmail,
    required this.businessPhoneNumber,
    required this.city,
    required this.state,
    required this.country,
    required this.instagram,
    required this.facebook,
    required this.sellingSince,
    required this.avgRating,
    required this.totalReviews,
    this.badge,
  });

  final int id;
  final String businessName;
  final String? businessLogo;
  final String? businessEmail;
  final String? businessPhoneNumber;
  final String? city;
  final String? state;
  final String? country;
  final String? instagram;
  final String? facebook;
  final DateTime? sellingSince;
  final num? avgRating;
  final int? totalReviews;
  final String? badge;

  static PublicSellerProfile fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    return PublicSellerProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      businessName: (json['business_name'] as String?) ?? '',
      businessLogo: json['business_logo'] as String?,
      businessEmail: json['business_email'] as String?,
      businessPhoneNumber: json['business_phone_number'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      sellingSince: DateTime.tryParse((json['selling_since'] as String?) ?? ''),
      avgRating: parseNum(json['avg_rating']),
      totalReviews: (parseNum(json['total_reviews']))?.toInt(),
      badge: json['badge'] as String?,
    );
  }
}
