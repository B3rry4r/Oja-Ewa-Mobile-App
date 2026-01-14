import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wishlist_repository_impl.dart';
import '../../domain/wishlist_item.dart';
import 'wishlist_controller.dart';

/// Deterministic wishlist IDs with optimistic toggle.
///
/// This avoids flicker/non-deterministic UI when using FutureProvider directly.
class WishlistIdsController extends AsyncNotifier<Set<String>> {
  @override
  FutureOr<Set<String>> build() async {
    final items = await ref.watch(wishlistRepositoryProvider).getWishlist();
    return items.map((w) => _key(w.type, w.wishlistableId)).toSet();
  }

  Future<void> toggle({required WishlistableType type, required int id}) async {
    final key = _key(type, id);
    final current = state.asData?.value ?? <String>{};
    final isIn = current.contains(key);

    // optimistic
    final next = <String>{...current};
    if (isIn) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = AsyncData(next);

    try {
      if (isIn) {
        await ref.read(wishlistRepositoryProvider).remove(type: type, id: id);
      } else {
        await ref.read(wishlistRepositoryProvider).add(type: type, id: id);
      }
      // keep full list in sync for wishlist screen
      ref.invalidate(wishlistProvider);
    } catch (e, st) {
      // revert on failure
      state = AsyncError(e, st);
      state = AsyncData(current);
      rethrow;
    }
  }

  static String _key(WishlistableType type, int id) => '${type.name}:$id';
}

final wishlistIdsProvider = AsyncNotifierProvider<WishlistIdsController, Set<String>>(
  WishlistIdsController.new,
);

final isWishlistedProvider = Provider.family<bool, ({WishlistableType type, int id})>((ref, args) {
  final key = '${args.type.name}:${args.id}';
  final ids = ref.watch(wishlistIdsProvider);
  return ids.maybeWhen(data: (set) => set.contains(key), orElse: () => false);
});
