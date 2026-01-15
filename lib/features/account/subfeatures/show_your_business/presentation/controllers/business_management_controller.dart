import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import '../../data/business_profile_api.dart';
import '../../domain/business_profile_payload.dart';

final businessProfileApiProvider = Provider<BusinessProfileApi>((ref) {
  return BusinessProfileApi(ref.watch(laravelDioProvider));
});

final businessByIdProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  return ref.watch(businessProfileApiProvider).getBusiness(id);
});

class BusinessManagementActions extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deactivate(int businessId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(businessProfileApiProvider).deactivateBusiness(businessId);
    });
  }

  Future<void> updateBusiness(int businessId, BusinessProfilePayload payload) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(businessProfileApiProvider).updateBusiness(businessId, payload);
    });
  }

  Future<void> renewSubscription({
    required int businessId,
    required String subscriptionType,
    required String billingCycle,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(businessProfileApiProvider).updateSubscription(
        businessId: businessId,
        subscriptionType: subscriptionType,
        billingCycle: billingCycle,
      );
    });
  }
}

final businessManagementActionsProvider = AsyncNotifierProvider<BusinessManagementActions, void>(
  BusinessManagementActions.new,
);
