import 'package:flutter/material.dart';

import '../theme/wb_theme_exports.dart';
import 'wb_icon.dart';
import 'wb_network_image.dart';

enum WBProductCardVariant { grid, row, carousel }

/// One product-card widget for every product surface, dishes, marketplace
/// items, search results, favorites, cart line previews. Bulk / sale / new
/// statuses surface as **tags** (top-left chip), not as separate widgets.
///
/// Three layout variants:
/// - [WBProductCardVariant.grid]  , 2-col grid tile (square image, name, vendor, price + add)
/// - [WBProductCardVariant.carousel], fixed-width horizontal scroll tile (same anatomy, 220 px wide)
/// - [WBProductCardVariant.row]   , horizontal list item with the image on the right
class WBProductCard extends StatelessWidget {
  const WBProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.vendorName,
    required this.priceLabel,
    this.unit,
    this.tag,
    this.description,
    this.variant = WBProductCardVariant.grid,
    this.onTap,
    this.onAdd,
  });

  final String imageUrl;
  final String name;
  final String vendorName;
  final String priceLabel;
  final String? unit;

  /// Optional top-left chip (e.g. `'BULK'`, `'NEW'`, `'-20%'`).
  final String? tag;

  /// Optional description, only rendered in the [WBProductCardVariant.row]
  /// variant where there's room.
  final String? description;

  final WBProductCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case WBProductCardVariant.grid:
        return _gridCard();
      case WBProductCardVariant.carousel:
        return SizedBox(width: 220, child: _gridCard());
      case WBProductCardVariant.row:
        return _rowCard();
    }
  }

  Widget _gridCard() {
    return GestureDetector(
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
            _imageBlock(radius: 14, aspect: 1.0),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: WBColors.fgHeader,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              vendorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgSecondary,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _priceBlock()),
                _addButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowCard() {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WBColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: WBShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null) ...[
                    _tagChip(tag!),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WBTypography.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendorName,
                    style: WBTypography.caption.copyWith(
                      color: WBColors.fgSecondary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: WBTypography.caption.copyWith(
                        color: WBColors.fgSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _priceBlock(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: WBNetworkImage(url: imageUrl),
                  ),
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: _addButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBlock({required double radius, required double aspect}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: WBNetworkImage(url: imageUrl),
          ),
          if (tag != null)
            Positioned(top: 10, left: 10, child: _tagChip(tag!)),
        ],
      ),
    );
  }

  Widget _tagChip(String label) {
    final isDark = label.toUpperCase() == 'BULK' || label.toUpperCase() == 'NEW';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? WBColors.surfaceDark
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(WBRadius.pill),
      ),
      child: Text(
        label,
        style: WBTypography.label.copyWith(
          color: isDark ? Colors.white : WBColors.fgHeader,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.55,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _priceBlock() {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: WBTypography.body.copyWith(
          color: WBColors.fgHeader,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        children: [
          TextSpan(text: priceLabel),
          if (unit != null)
            TextSpan(
              text: ' $unit',
              style: WBTypography.caption.copyWith(
                color: WBColors.fgPlaceholder,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: onAdd ?? onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: WBColors.surfaceDark,
          shape: BoxShape.circle,
          boxShadow: WBShadows.card,
        ),
        alignment: Alignment.center,
        child: const WBIcon(
          WBIconName.plus,
          size: 14,
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
