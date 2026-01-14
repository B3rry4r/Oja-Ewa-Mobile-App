import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sustainability_repository_impl.dart';

@immutable
class SustainabilityDetails {
  const SustainabilityDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.status,
    required this.progressPercentage,
  });

  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? category;
  final String? status;
  final num? progressPercentage;

  static SustainabilityDetails fromWrappedResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : json;

    return SustainabilityDetails(
      id: (payload['id'] as num?)?.toInt() ?? 0,
      title: (payload['title'] as String?) ?? '',
      description: payload['description'] as String?,
      imageUrl: payload['image_url'] as String? ?? payload['image'] as String?,
      category: payload['category'] as String?,
      status: payload['status'] as String?,
      progressPercentage: payload['progress_percentage'] as num?,
    );
  }
}

final sustainabilityDetailsProvider = FutureProvider.family<SustainabilityDetails, int>((ref, id) async {
  final json = await ref.watch(sustainabilityRepositoryProvider).getInitiative(id);
  return SustainabilityDetails.fromWrappedResponse(json);
});
