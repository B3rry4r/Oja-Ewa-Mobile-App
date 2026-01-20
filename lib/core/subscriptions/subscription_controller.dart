import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_constants.dart';
import 'subscription_models.dart';
import 'subscription_repository.dart';

/// Subscription state
class SubscriptionState {
  const SubscriptionState({
    this.isLoading = false,
    this.status,
    this.error,
  });

  final bool isLoading;
  final SubscriptionStatusResponse? status;
  final String? error;

  SubscriptionState copyWith({
    bool? isLoading,
    SubscriptionStatusResponse? status,
    String? error,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      error: error,
    );
  }

  /// Current subscription tier
  SubscriptionTier get tier => status?.tier ?? SubscriptionTier.free;

  /// Current features
  SubscriptionFeatureSet get features => 
      SubscriptionFeatures.forTier(status?.tier ?? SubscriptionTier.free);

  /// Whether user has an active subscription
  bool get hasActiveSubscription => status?.hasSubscription ?? false;

  /// Current subscription (if any)
  UserSubscription? get subscription => status?.subscription;
}

/// Controller for subscription management
class SubscriptionController extends AsyncNotifier<SubscriptionState> {
  @override
  FutureOr<SubscriptionState> build() async {
    // Load initial subscription status
    return _loadStatus();
  }

  Future<SubscriptionState> _loadStatus() async {
    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final status = await repository.getStatus();
      return SubscriptionState(status: status);
    } catch (e) {
      return SubscriptionState(error: 'Failed to load subscription status');
    }
  }

  /// Refresh subscription status from backend
  Future<void> refreshStatus() async {
    final currentState = state.value ?? const SubscriptionState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final status = await repository.getStatus();
      state = AsyncData(currentState.copyWith(isLoading: false, status: status));
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: 'Failed to refresh subscription status',
      ));
    }
  }

  /// Verify a purchase with the backend
  Future<VerifyPurchaseResponse?> verifyPurchase({
    required String productId,
    required String transactionId,
    required String receiptData,
    bool isSandbox = false,
  }) async {
    final currentState = state.value ?? const SubscriptionState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final response = await repository.verifyPurchase(
        VerifyPurchaseRequest(
          platform: Platform.isIOS ? 'ios' : 'android',
          productId: productId,
          transactionId: transactionId,
          receiptData: receiptData,
          environment: isSandbox ? 'sandbox' : 'production',
        ),
      );

      if (response.success && response.subscription != null) {
        // Refresh status to get updated features
        await refreshStatus();
      } else {
        state = AsyncData(currentState.copyWith(
          isLoading: false,
          error: response.error?.toString() ?? response.message,
        ));
      }

      return response;
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: 'Failed to verify purchase: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Clear any error
  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncData(currentState.copyWith(error: null));
    }
  }
}

/// Provider for Subscription Controller
final subscriptionControllerProvider =
    AsyncNotifierProvider<SubscriptionController, SubscriptionState>(
        SubscriptionController.new);

// ============================================================
// CONVENIENCE PROVIDERS
// ============================================================

/// Current subscription tier
final currentTierProvider = Provider<SubscriptionTier>((ref) {
  final subState = ref.watch(subscriptionControllerProvider).value;
  return subState?.tier ?? SubscriptionTier.free;
});

/// Current subscription features
final subscriptionFeaturesProvider = Provider<SubscriptionFeatureSet>((ref) {
  final subState = ref.watch(subscriptionControllerProvider).value;
  return subState?.features ?? SubscriptionFeatures.forTier(SubscriptionTier.free);
});

/// Whether user has active subscription
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  final subState = ref.watch(subscriptionControllerProvider).value;
  return subState?.hasActiveSubscription ?? false;
});

/// Check if user can access a specific feature
final canAccessFeatureProvider = Provider.family<bool, String>((ref, feature) {
  final features = ref.watch(subscriptionFeaturesProvider);
  
  switch (feature) {
    case 'ai_descriptions':
      return features.aiDescriptions;
    case 'ai_analytics':
      return features.aiAnalytics;
    case 'trend_predictions':
      return features.trendPredictions;
    case 'inventory_forecasting':
      return features.inventoryForecasting;
    case 'customer_insights':
      return features.customerInsights;
    case 'unlimited_products':
      return features.unlimitedProducts;
    case 'verified_badge':
      return features.verifiedBadge;
    case 'priority_support':
      return features.prioritySupport;
    case 'featured_placement':
      return features.featuredPlacement;
    default:
      return false;
  }
});

