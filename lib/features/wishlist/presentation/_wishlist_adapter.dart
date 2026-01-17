import '../../product/domain/product.dart';
import '../../../core/ui/price_formatter.dart';
import '../domain/wishlist_item.dart';

Product toUiProduct(WishlistItem w) {
  final priceLabel = w.price == null ? '' : formatPrice(w.price);
  return Product(
    id: w.wishlistableId.toString(),
    title: w.title.isEmpty ? '(Untitled)' : w.title,
    priceLabel: priceLabel,
    rating: 0,
    reviewCount: 0,
    imageUrl: w.imageUrl,
    imageColor: 0xFFD9D9D9,
    isFavorite: true,
  );
}
