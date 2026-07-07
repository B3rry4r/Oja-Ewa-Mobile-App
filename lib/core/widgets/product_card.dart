import 'package:flutter/material.dart';

import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/features/product/domain/product.dart';

/// Shared product card used across the app.
///
/// Re-skinned to the WAWUBasket design system (floating white card, soft
/// shadow, rounded image, bold price, dark action button). The constructor is
/// unchanged so every existing call-site keeps working.
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
    final hasImage =
        product.imageUrl != null && product.imageUrl!.trim().isNotEmpty;

    final Widget content = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: WBShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: hasImage
                        ? WBNetworkImage(url: product.imageUrl!)
                        : Container(color: WBColors.bgSoft),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: WBColors.surfaceDark,
                          shape: BoxShape.circle,
                          boxShadow: WBShadows.card,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: product.isFavorite
                              ? WBColors.statusError
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.priceLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const WBIcon(WBIconName.star, size: 13, color: WBColors.fgHeader),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: WBTypography.caption.copyWith(
                    fontSize: 12,
                    color: WBColors.fgHeader,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${product.reviewCount})',
                  style: WBTypography.caption.copyWith(
                    fontSize: 11,
                    color: WBColors.fgSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return width == null ? content : SizedBox(width: width, child: content);
  }
}
