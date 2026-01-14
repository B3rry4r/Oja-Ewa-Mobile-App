import 'package:flutter/foundation.dart';

@immutable
class ReviewUser {
  const ReviewUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  final int id;
  final String firstname;
  final String lastname;
  final String email;

  static ReviewUser fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstname: (json['firstname'] as String?) ?? '',
      lastname: (json['lastname'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }

  String get displayName {
    final n = ('${firstname.trim()} ${lastname.trim()}').trim();
    return n.isEmpty ? email : n;
  }
}

@immutable
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.headline,
    required this.body,
    required this.createdAt,
    required this.user,
  });

  final int id;
  final int rating;
  final String headline;
  final String body;
  final DateTime? createdAt;
  final ReviewUser? user;

  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      headline: (json['headline'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
      user: json['user'] is Map<String, dynamic> ? ReviewUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

@immutable
class ReviewsEntitySummary {
  const ReviewsEntitySummary({
    required this.id,
    required this.type,
    required this.avgRating,
  });

  final int id;
  final String type;
  final num? avgRating;

  static ReviewsEntitySummary fromJson(Map<String, dynamic> json) {
    return ReviewsEntitySummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] as String?) ?? '',
      avgRating: json['avg_rating'] as num?,
    );
  }
}

@immutable
class ReviewsPage {
  const ReviewsPage({
    required this.entity,
    required this.items,
    required this.total,
  });

  final ReviewsEntitySummary entity;
  final List<Review> items;
  final int total;

  static ReviewsPage fromJson(Map<String, dynamic> json) {
    final entity = ReviewsEntitySummary.fromJson(
      (json['entity'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
    );

    final reviews = (json['reviews'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final data = reviews['data'];
    final list = (data is List) ? data.whereType<Map<String, dynamic>>().map(Review.fromJson).toList() : <Review>[];

    final meta = (reviews['meta'] as Map?)?.cast<String, dynamic>();
    final total = (meta?['total'] as num?)?.toInt() ?? list.length;

    return ReviewsPage(entity: entity, items: list, total: total);
  }
}
