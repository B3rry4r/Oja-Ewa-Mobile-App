import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wishlist_repository_impl.dart';
import '../../domain/wishlist_item.dart';

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  return ref.watch(wishlistRepositoryProvider).getWishlist();
});

class WishlistActionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addItem({required WishlistableType type, required int id}) async {
    state = const AsyncLoading();
    try {
      await ref.read(wishlistRepositoryProvider).add(type: type, id: id);
      ref.invalidate(wishlistProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeItem({required WishlistableType type, required int id}) async {
    state = const AsyncLoading();
    try {
      await ref.read(wishlistRepositoryProvider).remove(type: type, id: id);
      ref.invalidate(wishlistProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> toggleItem({required WishlistableType type, required int id, required bool isInWishlist}) async {
    if (isInWishlist) {
      await removeItem(type: type, id: id);
    } else {
      await addItem(type: type, id: id);
    }
  }
}

final wishlistActionsProvider = AsyncNotifierProvider<WishlistActionsController, void>(WishlistActionsController.new);
