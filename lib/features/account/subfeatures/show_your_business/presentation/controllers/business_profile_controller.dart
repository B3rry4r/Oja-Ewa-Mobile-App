import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/business_profile_repository_impl.dart';
import '../../domain/business_profile_payload.dart';

class BusinessProfileController extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return null;
  }

  Future<Map<String, dynamic>> submit(BusinessProfilePayload payload) async {
    state = const AsyncLoading();
    try {
      final res = await ref.read(businessProfileRepositoryProvider).createBusiness(payload);
      state = AsyncData(res);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final businessProfileControllerProvider = AsyncNotifierProvider<BusinessProfileController, Map<String, dynamic>?>(
  BusinessProfileController.new,
);
