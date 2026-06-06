import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import 'package:ojaewa/features/app_services/shared/domain/app_service_purchase.dart';

import 'package:ojaewa/core/files/multipart_utils.dart';

import '../domain/badge_option.dart';
import '../domain/badge_verification_request.dart';

class BadgeVerificationsApi {
  BadgeVerificationsApi(this._dio);

  final Dio _dio;

  Future<List<BadgeOption>> getOptions() async {
    final response = await _dio.get(
      '/api/services/verification-badges/options',
    );
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? const {};
    final badges = payload['badges'];
    if (badges is! List) return const [];
    return badges
        .whereType<Map<String, dynamic>>()
        .map(BadgeOption.fromJson)
        .toList();
  }

  Future<List<BadgeVerificationRequest>> listRequests() async {
    final response = await _dio.get('/api/services/badge-verifications');
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
        .map(BadgeVerificationRequest.fromJson)
        .toList();
  }

  Future<BadgeVerificationRequest> createRequest({
    required String badge,
    required List<Map<String, dynamic>> documents,
    required Map<String, dynamic> answers,
    required AppServicePurchase purchase,
  }) async {
    final response = await _dio.post(
      '/api/services/badge-verifications',
      data: {
        'badge': badge,
        'documents': documents,
        'answers': answers,
        ...purchase.toJson(),
      },
    );
    final payload =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return BadgeVerificationRequest.fromJson(payload);
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String type,
  }) async {
    final form = FormData.fromMap({
      'file': await multipartFromPathCompressed(filePath),
      'type': type,
    });
    final response = await _dio.post(
      '/api/services/badge-verifications/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }
}

final badgeVerificationsApiProvider = Provider<BadgeVerificationsApi>((ref) {
  return BadgeVerificationsApi(ref.watch(laravelDioProvider));
});
