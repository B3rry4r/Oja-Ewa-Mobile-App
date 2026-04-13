import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';

import '../domain/cac_registration_request.dart';

class CacServicesApi {
  CacServicesApi(this._dio);

  final Dio _dio;
  static const callbackUrl = 'ojaewa://cac/payment/callback';

  Future<List<CacRegistrationRequest>> listRequests() async {
    final response = await _dio.get('/api/services/cac-registrations');
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
        .map(CacRegistrationRequest.fromJson)
        .toList();
  }

  Future<CacRegistrationRequest> createRequest({
    required String firstChoiceName,
    required String secondChoiceName,
    required bool acceptedNameModificationAuthorization,
    required bool consentToProcessRequest,
    required String businessObjective,
    required List<Map<String, dynamic>> proprietors,
    required String paymentReference,
    required String currency,
    required num amount,
    Map<String, dynamic>? rawData,
  }) async {
    final response = await _dio.post(
      '/api/services/cac-registrations',
      data: {
        'first_choice_name': firstChoiceName,
        'second_choice_name': secondChoiceName,
        'accepted_name_modification_authorization':
            acceptedNameModificationAuthorization,
        'consent_to_process_request': consentToProcessRequest,
        'business_objective': businessObjective,
        'proprietors': proprietors,
        'payment_provider': 'paystack',
        'payment_reference': paymentReference,
        'currency': currency,
        'amount': amount,
        if (rawData != null) 'raw_data': rawData,
      },
    );
    final payload =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return CacRegistrationRequest.fromJson(payload);
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String type,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': type,
    });
    final response = await _dio.post(
      '/api/services/cac-registrations/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  Future<String?> createPaymentLink() async {
    final response = await _dio.post(
      '/api/payment/link/cac',
      data: {'callback_url': callbackUrl},
    );
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? const {};
    return payload['payment_url'] as String?;
  }
}

final cacServicesApiProvider = Provider<CacServicesApi>((ref) {
  return CacServicesApi(ref.watch(laravelDioProvider));
});
