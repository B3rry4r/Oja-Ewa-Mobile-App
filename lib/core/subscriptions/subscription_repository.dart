import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_api.dart';
import 'subscription_models.dart';

/// Subscription Repository
/// 
/// Provides a clean interface for subscription operations with caching
/// and error handling.
class SubscriptionRepository {
  SubscriptionRepository(this._api);

  final SubscriptionApi _api;

  /// Verify a purchase with the backend
  Future<VerifyPurchaseResponse> verifyPurchase(VerifyPurchaseRequest request) async {
    return _api.verifyPurchase(request);
  }

  /// Get current subscription status
  Future<SubscriptionStatusResponse> getStatus() async {
    return _api.getSubscriptionStatus();
  }

  /// Get available subscription plans
  Future<SubscriptionPlansResponse> getPlans() async {
    return _api.getPlans();
  }

  /// Restore purchases
  Future<VerifyPurchaseResponse> restorePurchases(RestorePurchasesRequest request) async {
    return _api.restorePurchases(request);
  }

  /// Get subscription history
  Future<List<SubscriptionHistoryItem>> getHistory({int page = 1}) async {
    return _api.getHistory(page: page);
  }

  /// Get cancellation info
  Future<CancelInfoResponse> getCancelInfo() async {
    return _api.getCancelInfo();
  }
}

/// Provider for Subscription Repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final api = ref.watch(subscriptionApiProvider);
  return SubscriptionRepository(api);
});
