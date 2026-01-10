import 'package:flutter/material.dart';

import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/product/domain/product.dart';

/// Shared product card used across the app.
///
/// This design is extracted from the Product Details "You may also like" section
/// and replaces the older default product card.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onFavoriteTap,
    this.width,
  });

  final Product product;
  final VoidCallback onTap;

  /// Kept for backward compatibility with existing call-sites.
  /// In this design it maps to the bag/action button.
  final VoidCallback onFavoriteTap;

  /// Optional fixed width for horizontal lists.
  /// When null, the card expands to fit parent constraints (responsive).
  final double? width;

  @override
  Widget build(BuildContext context) {
    final imageColor = Color(product.imageColor ?? 0xFFD9D9D9);

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Container(
              height: 152,
              decoration: BoxDecoration(
                color: imageColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: AppImagePlaceholder(
                      width: 96,
                      height: 96,
                      borderRadius: 0,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDAF40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF241508),
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              product.priceLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF241508),
                fontFamily: 'Campton',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFDB80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF241508),
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${product.reviewCount})',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF777F84),
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: width == null ? content : SizedBox(width: width, child: content),
    );
  }
}
