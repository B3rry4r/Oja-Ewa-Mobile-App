import 'package:flutter/foundation.dart';

@immutable
class Advert {
  const Advert({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
    required this.position,
    required this.priority,
  });

  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? actionUrl;
  final String? position;
  final int? priority;

  static Advert fromJson(Map<String, dynamic> json) {
    return Advert(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      actionUrl: json['action_url'] as String?,
      position: json['position'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
    );
  }
}
