import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/network/dio_clients.dart';

import '../../data/business_status_api.dart';
import '../../domain/business_status.dart';

final businessStatusApiProvider = Provider<BusinessStatusApi>((ref) {
  return BusinessStatusApi(ref.watch(laravelDioProvider));
});

/// Fetches the current user's business profiles (auth required).
final myBusinessStatusesProvider = FutureProvider<List<BusinessStatus>>((ref) async {
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return const [];
  return ref.watch(businessStatusApiProvider).getMyBusinesses();
});

/// Convenience: whether the user has any approved business.
final hasApprovedBusinessProvider = Provider<bool>((ref) {
  final async = ref.watch(myBusinessStatusesProvider);
  return async.maybeWhen(
    data: (items) => items.any((b) => b.storeStatus == 'approved'),
    orElse: () => false,
  );
});
