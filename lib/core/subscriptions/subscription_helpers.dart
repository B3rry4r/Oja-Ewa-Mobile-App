import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/presentation/controllers/profile_controller.dart';
import 'subscription_constants.dart';

/// Helper to determine which subscription product to show based on user's MTN status
final subscriptionProductIdProvider = Provider<String>((ref) {
  // Watch the user profile to check MTN eligibility
  final profileAsync = ref.watch(userProfileProvider);
  
  final isMtnEligible = profileAsync.whenOrNull(
    data: (profile) => profile?.isEligibleForMtnDiscount ?? false,
  ) ?? false;
  
  // Return MTN product if eligible, otherwise standard product
  return isMtnEligible 
      ? SubscriptionProducts.ojaewaProYearlyMtn 
      : SubscriptionProducts.ojaewaProYearly;
});
