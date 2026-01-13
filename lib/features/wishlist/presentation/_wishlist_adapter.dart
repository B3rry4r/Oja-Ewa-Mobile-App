import '../../product/domain/product.dart';
import '../domain/wishlist_item.dart';

Product toUiProduct(WishlistItem w) {
  final priceLabel = w.price == null ? '' : '₦${w.price}';
  return Product(
    id: w.wishlistableId.toString(),
    title: w.title.isEmpty ? '(Untitled)' : w.title,
    priceLabel: priceLabel,
    rating: 0,
    reviewCount: 0,
    isFavorite: true,
  );
}
