import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';

class SchoolRegistrationApi {
  SchoolRegistrationApi(this._dio);

  final Dio _dio;

  /// Submit school registration application
  /// Public endpoint - no authentication required
  Future<Map<String, dynamic>> submitRegistration({
    required String country,
    required String fullName,
    required String phoneNumber,
    required String state,
    required String city,
    required String address,
    int? businessId,
  }) async {
    try {
      final body = <String, dynamic>{
        'country': country,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'state': state,
        'city': city,
        'address': address,
      };
      if (businessId != null) {
        body['business_id'] = businessId;
      }

      final res = await _dio.post('/api/school-registrations', data: body);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Generate Paystack payment link for school registration
  /// Requires authentication
  Future<Map<String, dynamic>> createPaymentLink({
    required int registrationId,
    required String email,
  }) async {
    try {
      final res = await _dio.post('/api/payment/link/school', data: {
        'registration_id': registrationId,
        'email': email,
      });
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Verify payment status
  Future<Map<String, dynamic>> verifyPayment({
    required String reference,
  }) async {
    try {
      final res = await _dio.post('/api/payment/verify', data: {
        'reference': reference,
      });
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      throw const FormatException('Unexpected response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
