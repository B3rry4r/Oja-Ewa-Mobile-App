import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';

import '../domain/nepc_registration_request.dart';

class NepcServicesApi {
  NepcServicesApi(this._dio);

  final Dio _dio;
  static const callbackUrl = 'ojaewa://nepc/payment/callback';

  Future<List<NepcRegistrationRequest>> listRequests() async {
    final response = await _dio.get('/api/services/nepc-registrations');
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
        .map(NepcRegistrationRequest.fromJson)
        .toList();
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
      '/api/services/nepc-registrations/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createPaymentLink({
    required String applicationType,
  }) async {
    final response = await _dio.post(
      '/api/payment/link/nepc',
      data: {'application_type': applicationType, 'callback_url': callbackUrl},
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<NepcRegistrationRequest> createRequest({
    required String applicationType,
    required String businessType,
    required List<Map<String, dynamic>> documents,
    required String businessName,
    required String registrationNumber,
    required String businessAddress,
    required String fullName,
    required String phoneNumber,
    required String email,
    required String productsToExport,
    required bool confirmedInformation,
    required String paymentReference,
    required String currency,
    required num amount,
  }) async {
    final response = await _dio.post(
      '/api/services/nepc-registrations',
      data: {
        'application_type': applicationType,
        'business_type': businessType,
        'documents': documents,
        'business_name': businessName,
        'registration_number': registrationNumber,
        'business_address': businessAddress,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'products_to_export': productsToExport,
        'confirmed_information': confirmedInformation,
        'payment_provider': 'paystack',
        'payment_reference': paymentReference,
        'currency': currency,
        'amount': amount,
      },
    );
    final payload =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return NepcRegistrationRequest.fromJson(payload);
  }
}

final nepcServicesApiProvider = Provider<NepcServicesApi>((ref) {
  return NepcServicesApi(ref.watch(laravelDioProvider));
});
