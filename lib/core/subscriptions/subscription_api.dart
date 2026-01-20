import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_clients.dart';
import 'subscription_models.dart';

/// Subscription API Service
/// 
/// Handles all subscription-related API calls to the Laravel backend.
class SubscriptionApi {
  SubscriptionApi(this._dio);

  final Dio _dio;

  /// Verify a purchase with the backend
  /// Called after successful IAP purchase from App Store / Play Store
  Future<VerifyPurchaseResponse> verifyPurchase(VerifyPurchaseRequest request) async {
    final response = await _dio.post(
      '/subscriptions/verify',
      data: request.toJson(),
    );
    return VerifyPurchaseResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get current subscription status
  Future<SubscriptionStatusResponse> getSubscriptionStatus() async {
    final response = await _dio.get('/subscriptions/status');
    return SubscriptionStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }

}

/// Provider for Subscription API
final subscriptionApiProvider = Provider<SubscriptionApi>((ref) {
  final dio = ref.watch(laravelDioProvider);
  return SubscriptionApi(dio);
});
