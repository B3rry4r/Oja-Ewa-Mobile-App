import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/seller_profile_repository_impl.dart';
import '../../domain/seller_profile_payload.dart';

class SellerProfileController extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return null;
  }

  Future<Map<String, dynamic>> submit(SellerProfilePayload payload) async {
    state = const AsyncLoading();
    try {
      final res = await ref.read(sellerProfileRepositoryProvider).createSellerProfile(payload);
      state = AsyncData(res);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final sellerProfileControllerProvider = AsyncNotifierProvider<SellerProfileController, Map<String, dynamic>?>(
  SellerProfileController.new,
);
