import 'package:flutter/foundation.dart';
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
final mySellerStatusProvider = FutureProvider.autoDispose<SellerStatus?>((ref) async {
  debugPrint('[mySellerStatusProvider] Provider executing...');
  
  final token = ref.watch(accessTokenProvider);
  debugPrint('[mySellerStatusProvider] Token: ${token != null && token.isNotEmpty ? "present (${token.substring(0, 10)}...)" : "MISSING"}');
  
  if (token == null || token.isEmpty) {
    debugPrint('[mySellerStatusProvider] No token, returning null');
    return null;
  }
  
  try {
    debugPrint('[mySellerStatusProvider] Calling API...');
    final result = await ref.read(sellerStatusApiProvider).getMySellerProfile();
    debugPrint('[mySellerStatusProvider] API result: $result');
    debugPrint('[mySellerStatusProvider] isApprovedAndActive: ${result?.isApprovedAndActive}');
    return result;
  } catch (e, st) {
    // On any error, return null - don't block the UI
    // This handles network errors, 401s, etc.
    debugPrint('[mySellerStatusProvider] Error caught: $e');
    debugPrint('[mySellerStatusProvider] Stack trace: $st');
    return null;
  }
});

/// Returns true if the current user has an approved and active seller profile.
/// Returns false if not approved, not active, no profile, not authenticated, or on error.
final isSellerApprovedProvider = Provider<bool>((ref) {
  final async = ref.watch(mySellerStatusProvider);
  final result = async.maybeWhen(
    data: (s) => s?.isApprovedAndActive ?? false,
    orElse: () => false,
  );
  debugPrint('[isSellerApprovedProvider] Result: $result');
  return result;
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
