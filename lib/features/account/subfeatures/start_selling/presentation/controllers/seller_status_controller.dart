import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/network/dio_clients.dart';

import '../../data/seller_status_api.dart';
import '../../domain/seller_status.dart';

final sellerStatusApiProvider = Provider<SellerStatusApi>((ref) {
  return SellerStatusApi(ref.watch(laravelDioProvider));
});

final mySellerStatusProvider = FutureProvider<SellerStatus?>((ref) async {
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return null;
  return ref.watch(sellerStatusApiProvider).getMySellerProfile();
});

final isSellerApprovedProvider = Provider<bool>((ref) {
  final async = ref.watch(mySellerStatusProvider);
  return async.maybeWhen(
    data: (s) => s?.isApprovedAndActive ?? false,
    orElse: () => false,
  );
});
