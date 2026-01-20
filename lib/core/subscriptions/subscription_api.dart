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

  /// Get available subscription plans
  Future<SubscriptionPlansResponse> getPlans() async {
    final response = await _dio.get('/subscriptions/plans');
    return SubscriptionPlansResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Restore purchases
  Future<VerifyPurchaseResponse> restorePurchases(RestorePurchasesRequest request) async {
    final response = await _dio.post(
      '/subscriptions/restore',
      data: request.toJson(),
    );
    return VerifyPurchaseResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get subscription history
  Future<List<SubscriptionHistoryItem>> getHistory({int page = 1, int perPage = 20}) async {
    final response = await _dio.get(
      '/subscriptions/history',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    
    final data = response.data as Map<String, dynamic>;
    final history = data['data']?['history'] as List<dynamic>? ?? [];
    
    return history
        .map((item) => SubscriptionHistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get cancellation info
  Future<CancelInfoResponse> getCancelInfo() async {
    final response = await _dio.get('/subscriptions/cancel-info');
    return CancelInfoResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Provider for Subscription API
final subscriptionApiProvider = Provider<SubscriptionApi>((ref) {
  final dio = ref.watch(laravelDioProvider);
  return SubscriptionApi(dio);
});
