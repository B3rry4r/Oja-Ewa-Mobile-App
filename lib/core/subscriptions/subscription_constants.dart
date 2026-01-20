/// Subscription Constants
/// 
/// Product IDs and tier definitions for IAP subscriptions.
/// These IDs must match exactly what's configured in App Store Connect
/// and Google Play Console.

/// Subscription Product IDs
class SubscriptionProducts {
  SubscriptionProducts._();

  /// Ojaewa Pro - Yearly subscription
  /// Price: Set in App Store/Play Console
  static const String ojaewaProYearly = 'ojaewa_pro';

  /// All available product IDs
  static const List<String> allProducts = [
    ojaewaProYearly,
  ];
}

/// Subscription Tiers
enum SubscriptionTier {
  free('free', 'Free'),
  ojaewaPro('ojaewa_pro', 'Ojaewa Pro');

  const SubscriptionTier(this.id, this.displayName);

  final String id;
  final String displayName;

  static SubscriptionTier fromId(String? id) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.id == id,
      orElse: () => SubscriptionTier.free,
    );
  }

  static SubscriptionTier fromProductId(String? productId) {
    switch (productId) {
      case SubscriptionProducts.ojaewaProYearly:
        return SubscriptionTier.ojaewaPro;
      default:
        return SubscriptionTier.free;
    }
  }

  bool get isFree => this == SubscriptionTier.free;
  bool get isPaid => this != SubscriptionTier.free;
  bool get isOjaewaPro => this == SubscriptionTier.ojaewaPro;
}

/// Subscription Status
enum SubscriptionStatus {
  active('active'),
  expired('expired'),
  cancelled('cancelled'),
  gracePeriod('grace_period'),
  paused('paused');

  const SubscriptionStatus(this.value);

  final String value;

  static SubscriptionStatus fromString(String? value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }

  bool get isActive => this == SubscriptionStatus.active || this == SubscriptionStatus.gracePeriod;
}

/// Feature flags by subscription tier
class SubscriptionFeatures {
  SubscriptionFeatures._();

  /// Get features for a given tier
  static SubscriptionFeatureSet forTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return const SubscriptionFeatureSet(
          maxProducts: 10,
          unlimitedProducts: false,
          aiDescriptions: false,
          aiAnalytics: false,
          trendPredictions: false,
          inventoryForecasting: false,
          customerInsights: false,
          verifiedBadge: false,
          prioritySupport: false,
          featuredPlacement: false,
        );
      case SubscriptionTier.ojaewaPro:
        return const SubscriptionFeatureSet(
          maxProducts: -1, // unlimited
          unlimitedProducts: true,
          aiDescriptions: true,
          aiAnalytics: true,
          trendPredictions: true,
          inventoryForecasting: true,
          customerInsights: true,
          verifiedBadge: true,
          prioritySupport: true,
          featuredPlacement: true,
        );
    }
  }
}

/// Feature set for a subscription tier
class SubscriptionFeatureSet {
  const SubscriptionFeatureSet({
    required this.maxProducts,
    required this.unlimitedProducts,
    required this.aiDescriptions,
    required this.aiAnalytics,
    required this.trendPredictions,
    required this.inventoryForecasting,
    required this.customerInsights,
    required this.verifiedBadge,
    required this.prioritySupport,
    required this.featuredPlacement,
  });

  final int maxProducts;
  final bool unlimitedProducts;
  final bool aiDescriptions;
  final bool aiAnalytics;
  final bool trendPredictions;
  final bool inventoryForecasting;
  final bool customerInsights;
  final bool verifiedBadge;
  final bool prioritySupport;
  final bool featuredPlacement;

  factory SubscriptionFeatureSet.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeatureSet(
      maxProducts: json['max_products'] as int? ?? 10,
      unlimitedProducts: json['unlimited_products'] as bool? ?? false,
      aiDescriptions: json['ai_descriptions'] as bool? ?? false,
      aiAnalytics: json['ai_analytics'] as bool? ?? false,
      trendPredictions: json['trend_predictions'] as bool? ?? false,
      inventoryForecasting: json['inventory_forecasting'] as bool? ?? false,
      customerInsights: json['customer_insights'] as bool? ?? false,
      verifiedBadge: json['verified_badge'] as bool? ?? false,
      prioritySupport: json['priority_support'] as bool? ?? false,
      featuredPlacement: json['featured_placement'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'max_products': maxProducts,
    'unlimited_products': unlimitedProducts,
    'ai_descriptions': aiDescriptions,
    'ai_analytics': aiAnalytics,
    'trend_predictions': trendPredictions,
    'inventory_forecasting': inventoryForecasting,
    'customer_insights': customerInsights,
    'verified_badge': verifiedBadge,
    'priority_support': prioritySupport,
    'featured_placement': featuredPlacement,
  };
}
