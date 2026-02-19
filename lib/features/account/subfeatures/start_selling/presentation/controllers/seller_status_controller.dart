import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/network/dio_clients.dart';

import '../../data/seller_status_api.dart';
import '../../domain/seller_status.dart';

final sellerStatusApiProvider = Provider<SellerStatusApi>((ref) {
  return SellerStatusApi(ref.watch(laravelDioProvider));
});

/// Fetches the current user's seller profile status.
/// Returns null if user has no seller profile or is not authenticated.
/// Auto-disposes to ensure fresh data when navigating back to screens.
class SellerStatusOverrideController extends Notifier<SellerStatus?> {
  @override
  SellerStatus? build() => null;

  void setStatus(SellerStatus? status) {
    state = status;
  }
}

final sellerStatusOverrideProvider = NotifierProvider<SellerStatusOverrideController, SellerStatus?>(
  SellerStatusOverrideController.new,
);

final mySellerStatusProvider = FutureProvider.autoDispose<SellerStatus?>((ref) async {
  final override = ref.watch(sellerStatusOverrideProvider);
  if (override != null) {
    return override;
  }
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) {
    return null;
  }

  try {
    return await ref.read(sellerStatusApiProvider).getMySellerProfile();
  } catch (_) {
    // On any error, return null - don't block the UI
    return null;
  }
});

/// Returns true if the current user has an approved and active seller profile.
/// Returns false if not approved, not active, no profile, not authenticated, or on error.
final isSellerApprovedProvider = Provider<bool>((ref) {
  final async = ref.watch(mySellerStatusProvider);
  return async.maybeWhen(
    data: (s) => s?.isApprovedAndActive ?? false,
    orElse: () => false,
  );
});

/// Returns the seller status directly (for more detailed checks).
/// Null if loading, error, or no seller profile.
final sellerStatusProvider = Provider<SellerStatus?>((ref) {
  final async = ref.watch(mySellerStatusProvider);
  return async.maybeWhen(
    data: (s) => s,
    orElse: () => null,
  );
});
