import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';
import '../domain/wishlist_item.dart';
import '../domain/wishlist_repository.dart';
import 'wishlist_api.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._api);

  final WishlistApi _api;

  @override
  Future<void> add({required WishlistableType type, required int id}) => _api.add(type: type, id: id);

  @override
  Future<List<WishlistItem>> getWishlist() => _api.getWishlist();

  @override
  Future<void> remove({required WishlistableType type, required int id}) => _api.remove(type: type, id: id);
}

final wishlistApiProvider = Provider<WishlistApi>((ref) {
  return WishlistApi(ref.watch(laravelDioProvider));
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(ref.watch(wishlistApiProvider));
});
