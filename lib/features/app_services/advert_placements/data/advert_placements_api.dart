import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import 'package:ojaewa/features/app_services/shared/domain/app_service_purchase.dart';

import '../domain/advert_placement_request.dart';

class AdvertPlacementsApi {
  AdvertPlacementsApi(this._dio);

  final Dio _dio;

  Future<List<AdvertPlacementRequest>> listRequests() async {
    final response = await _dio.get('/api/services/advert-placements');
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'];
    final items = payload is List
        ? payload
        : payload is Map<String, dynamic>
        ? payload['data']
        : const [];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdvertPlacementRequest.fromJson)
        .toList();
  }

  Future<AdvertPlacementRequest> createRequest({
    required String title,
    required String description,
    required String placement,
    required String mediaType,
    String? imageUrl,
    String? videoUrl,
    String? videoSource,
    String? thumbnailUrl,
    required String targetUrl,
    required String startDate,
    required String endDate,
    required String displayCurrency,
    required num displayTotalAmount,
    required AppServicePurchase purchase,
  }) async {
    final response = await _dio.post(
      '/api/services/advert-placements',
      data: {
        'title': title,
        'description': description,
        'placement': placement,
        'media_type': mediaType,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
        if (videoSource != null && videoSource.isNotEmpty)
          'video_source': videoSource,
        if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          'thumbnail_url': thumbnailUrl,
        'target_url': targetUrl,
        'start_date': startDate,
        'end_date': endDate,
        'display_currency': displayCurrency,
        'display_total_amount': displayTotalAmount,
        ...purchase.toJson(),
      },
    );
    final payload =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return AdvertPlacementRequest.fromJson(payload);
  }
}

final advertPlacementsApiProvider = Provider<AdvertPlacementsApi>((ref) {
  return AdvertPlacementsApi(ref.watch(laravelDioProvider));
});
