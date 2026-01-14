class Product {
  const Product({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
    this.imageColor,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String priceLabel;
  final double rating;
  final int reviewCount;

  /// Network image url for this product.
  final String? imageUrl;

  /// Placeholder background color if no image.
  final int? imageColor;

  /// Temporary local state.
  final bool isFavorite;
}
