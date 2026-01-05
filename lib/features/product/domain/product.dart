class Product {
  const Product({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.rating,
    required this.reviewCount,
    this.imageColor,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String priceLabel;
  final double rating;
  final int reviewCount;

  /// Temporary placeholder until we have real images.
  final int? imageColor;

  /// Temporary local state (will come from backend/storage later).
  final bool isFavorite;
}
