import 'subscription_constants.dart';

/// User's subscription data
class UserSubscription {
  const UserSubscription({
    required this.id,
    required this.productId,
    required this.tier,
    required this.status,
    required this.platform,
    required this.startsAt,
    required this.expiresAt,
    required this.isAutoRenewing,
    required this.willRenew,
    this.cancelledAt,
    this.daysRemaining,
  });

  final int id;
  final String productId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final String platform;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool isAutoRenewing;
  final bool willRenew;
  final DateTime? cancelledAt;
  final int? daysRemaining;

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as int,
      productId: json['product_id'] as String,
      tier: SubscriptionTier.fromId(json['tier'] as String?),
      status: SubscriptionStatus.fromString(json['status'] as String?),
      platform: json['platform'] as String? ?? 'unknown',
      startsAt: DateTime.parse(json['starts_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isAutoRenewing: json['is_auto_renewing'] as bool? ?? false,
      willRenew: json['will_renew'] as bool? ?? false,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
      daysRemaining: json['days_remaining'] as int?,
    );
  }

  bool get isActive => status.isActive;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  SubscriptionFeatureSet get features => SubscriptionFeatures.forTier(tier);
}

/// Subscription status response from API
class SubscriptionStatusResponse {
  const SubscriptionStatusResponse({
    required this.hasSubscription,
    this.subscription,
  });

  final bool hasSubscription;
  final UserSubscription? subscription;

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SubscriptionStatusResponse(
      hasSubscription: data['has_subscription'] as bool? ?? false,
      subscription: data['subscription'] != null
          ? UserSubscription.fromJson(data['subscription'] as Map<String, dynamic>)
          : null,
    );
  }

  SubscriptionTier get tier => subscription?.tier ?? SubscriptionTier.free;
}

/// Subscription plan for display
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.productId,
    required this.name,
    required this.description,
    required this.tier,
    required this.duration,
    required this.price,
    required this.featuresList,
    this.isPopular = false,
  });

  final String productId;
  final String name;
  final String description;
  final SubscriptionTier tier;
  final String duration;
  final SubscriptionPrice price;
  final List<String> featuresList;
  final bool isPopular;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      tier: SubscriptionTier.fromId(json['tier'] as String?),
      duration: json['duration'] as String? ?? 'yearly',
      price: SubscriptionPrice.fromJson(json['price'] as Map<String, dynamic>),
      featuresList: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      isPopular: json['popular'] as bool? ?? false,
    );
  }
}

/// Subscription price
class SubscriptionPrice {
  const SubscriptionPrice({
    required this.amount,
    required this.currency,
    required this.formatted,
  });

  final double amount;
  final String currency;
  final String formatted;

  factory SubscriptionPrice.fromJson(Map<String, dynamic> json) {
    return SubscriptionPrice(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      formatted: json['formatted'] as String? ?? '',
    );
  }
}

/// Plans response from API
class SubscriptionPlansResponse {
  const SubscriptionPlansResponse({
    required this.plans,
    this.freeTier,
  });

  final List<SubscriptionPlan> plans;
  final FreeTierInfo? freeTier;

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SubscriptionPlansResponse(
      plans: (data['plans'] as List<dynamic>?)
          ?.map((p) => SubscriptionPlan.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      freeTier: data['free_tier'] != null
          ? FreeTierInfo.fromJson(data['free_tier'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Free tier info
class FreeTierInfo {
  const FreeTierInfo({
    required this.name,
    required this.features,
  });

  final String name;
  final List<String> features;

  factory FreeTierInfo.fromJson(Map<String, dynamic> json) {
    return FreeTierInfo(
      name: json['name'] as String? ?? 'Free',
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

/// Purchase verification request
class VerifyPurchaseRequest {
  const VerifyPurchaseRequest({
    required this.platform,
    required this.productId,
    required this.transactionId,
    required this.receiptData,
    this.environment = 'production',
  });

  final String platform;
  final String productId;
  final String transactionId;
  final String receiptData;
  final String environment;

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'product_id': productId,
    'transaction_id': transactionId,
    'receipt_data': receiptData,
    'environment': environment,
  };
}

/// Purchase verification response
class VerifyPurchaseResponse {
  const VerifyPurchaseResponse({
    required this.success,
    required this.message,
    this.subscription,
    this.features,
    this.error,
  });

  final bool success;
  final String message;
  final UserSubscription? subscription;
  final SubscriptionFeatureSet? features;
  final PurchaseError? error;

  factory VerifyPurchaseResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return VerifyPurchaseResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      subscription: data?['subscription'] != null
          ? UserSubscription.fromJson(data!['subscription'] as Map<String, dynamic>)
          : null,
      features: data?['features'] != null
          ? SubscriptionFeatureSet.fromJson(data!['features'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? PurchaseError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Purchase error
class PurchaseError {
  const PurchaseError({
    required this.code,
    this.details,
  });

  final String code;
  final String? details;

  factory PurchaseError.fromJson(Map<String, dynamic> json) {
    return PurchaseError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      details: json['details'] as String?,
    );
  }

  @override
  String toString() => '$code: ${details ?? 'No details'}';
}

/// Restore purchases request
class RestorePurchasesRequest {
  const RestorePurchasesRequest({
    required this.platform,
    this.receiptData,
    this.purchaseTokens,
  });

  final String platform;
  final String? receiptData;
  final List<String>? purchaseTokens;

  Map<String, dynamic> toJson() => {
    'platform': platform,
    if (receiptData != null) 'receipt_data': receiptData,
    if (purchaseTokens != null) 'purchase_tokens': purchaseTokens,
  };
}

/// Subscription history item
class SubscriptionHistoryItem {
  const SubscriptionHistoryItem({
    required this.id,
    required this.eventType,
    required this.productId,
    required this.tier,
    required this.createdAt,
    this.eventData,
  });

  final int id;
  final String eventType;
  final String productId;
  final SubscriptionTier tier;
  final DateTime createdAt;
  final Map<String, dynamic>? eventData;

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      id: json['id'] as int,
      eventType: json['event_type'] as String,
      productId: json['product_id'] as String? ?? '',
      tier: SubscriptionTier.fromId(json['tier'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      eventData: json['event_data'] as Map<String, dynamic>?,
    );
  }

  String get eventTypeDisplayName {
    switch (eventType) {
      case 'purchased':
        return 'Subscribed';
      case 'renewed':
        return 'Renewed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'reactivated':
        return 'Reactivated';
      case 'upgraded':
        return 'Upgraded';
      case 'downgraded':
        return 'Downgraded';
      case 'refunded':
        return 'Refunded';
      default:
        return eventType;
    }
  }
}

/// Cancel info response
class CancelInfoResponse {
  const CancelInfoResponse({
    required this.iosCancellationUrl,
    required this.androidCancellationUrl,
    required this.message,
    this.expiresAt,
  });

  final String iosCancellationUrl;
  final String androidCancellationUrl;
  final String message;
  final DateTime? expiresAt;

  factory CancelInfoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final urls = data['cancellation_url'] as Map<String, dynamic>? ?? {};
    final subscription = data['current_subscription'] as Map<String, dynamic>?;
    
    return CancelInfoResponse(
      iosCancellationUrl: urls['ios'] as String? ?? 'https://apps.apple.com/account/subscriptions',
      androidCancellationUrl: urls['android'] as String? ?? 'https://play.google.com/store/account/subscriptions',
      message: data['message'] as String? ?? '',
      expiresAt: subscription?['expires_at'] != null
          ? DateTime.parse(subscription!['expires_at'] as String)
          : null,
    );
  }
}
