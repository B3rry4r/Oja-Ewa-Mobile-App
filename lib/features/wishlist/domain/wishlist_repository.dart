import 'wishlist_item.dart';

abstract interface class WishlistRepository {
  Future<List<WishlistItem>> getWishlist();
  Future<void> add({required WishlistableType type, required int id});
  Future<void> remove({required WishlistableType type, required int id});
}
