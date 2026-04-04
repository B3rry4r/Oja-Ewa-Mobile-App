import 'package:flutter/material.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/info_bottom_sheet.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/core/widgets/seller_badge.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product/presentation/controllers/product_details_controller.dart';
import 'package:ojaewa/features/product_detail/presentation/seller_profile.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';
import 'package:ojaewa/features/wishlist/presentation/controllers/wishlist_ids_controller.dart';
import 'package:ojaewa/features/wishlist/domain/wishlist_item.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailsScreen> {
  String selectedSize = 'S';
  int quantity = 1;
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Do not change layout; only populate data.
    final detailsAsync = ref.watch(productDetailsProvider(widget.productId));
    final accessToken = ref.watch(accessTokenProvider);
    final isLoggedIn = accessToken != null && accessToken.isNotEmpty;

    if (detailsAsync.isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (detailsAsync.hasError) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  'Unable to load product details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colors.textTertiary),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      ref.refresh(productDetailsProvider(widget.productId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final details = detailsAsync.value!;

    final isWishlisted = ref.watch(
      isWishlistedProvider((
        type: WishlistableType.product,
        id: widget.productId,
      )),
    );

    final reviewsPage = ref
        .watch(reviewsProvider((type: 'product', id: widget.productId)))
        .maybeWhen(data: (d) => d, orElse: () => null);

    final firstReview = (reviewsPage?.items.isNotEmpty ?? false)
        ? reviewsPage!.items.first
        : null;

    final productTitle = (details?.name ?? '').trim();
    final sellerName = (details?.sellerBusinessName ?? '').trim();
    final imageUrl = (details?.image ?? '').trim();
    num? parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    final unitPrice = parseNum(details?.price);
    final totalPrice = unitPrice == null ? null : (unitPrice * quantity);

    // Bottom bar uses total (quantity-aware). One decimal for stability.
    final priceLabel = totalPrice == null ? '' : formatPrice(totalPrice);

    // Processing cards should show unit price (not multiplied) to keep original meaning.
    final unitPriceLabel = unitPrice == null ? '' : formatPrice(unitPrice);

    final reviewCount = reviewsPage?.total ?? 0;
    final avgRating = reviewsPage?.entity.avgRating?.toString() ?? '';

    final reviewUser = (firstReview?.user?.displayName ?? '');
    final reviewDate = firstReview?.createdAt == null
        ? ''
        : _formatDate(firstReview!.createdAt!);
    final reviewHeadline = (firstReview?.headline ?? '');
    final reviewBody = (firstReview?.body ?? '').trim();

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image carousel
                _buildImageCarousel(imageUrl.isEmpty ? null : imageUrl),

                const SizedBox(height: 13),

                // Image indicators
                _buildImageIndicators(),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product title and favorite button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(wishlistIdsProvider.notifier)
                                  .toggle(
                                    type: WishlistableType.product,
                                    id: widget.productId,
                                  );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: colors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (sellerName.isNotEmpty)
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Campton',
                              color: colors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'by '),
                              TextSpan(
                                text: sellerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (details?.sellerBadge != null) ...[
                        const SizedBox(height: 6),
                        SellerBadge(badge: details?.sellerBadge),
                      ],

                      const SizedBox(height: 24),

                      // Size selection - only show if product has sizes (textiles, shoes_bags)
                      // Art and beauty products don't have sizes
                      if (details?.size != null &&
                          details!.size!.isNotEmpty) ...[
                        Text(
                          'Size',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 5),

                        _buildSizeSelector(details.size),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'View Size Chart',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                      ],

                      // Processing time section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processing Time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Select your package type',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildProcessingInfo(unitPriceLabel),

                      const SizedBox(height: 24),

                      // Expandable sections
                      _buildExpandableSection(
                        'Description',
                        Icons.add,
                        onTap: () {
                          InfoBottomSheet.show(
                            context,
                            title: 'Description',
                            content: Text(
                              (details?.description ?? ''),
                              style: TextStyle(
                                fontFamily: 'Campton',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          );
                        },
                      ),

                      _buildExpandableSection(
                        'Return Policy',
                        Icons.add,
                        onTap: () {},
                      ),

                      // Reviews section (inline + More)
                      _buildReviewsSection(
                        reviewCount: reviewCount,
                        avgRating: avgRating,
                        user: reviewUser,
                        date: reviewDate,
                        headline: reviewHeadline,
                        body: reviewBody,
                        onMore: () => Navigator.of(context).pushNamed(
                          AppRoutes.reviews,
                          arguments: {
                            'type': 'product',
                            'id': widget.productId,
                          },
                        ),
                      ),

                      if (isLoggedIn)
                        _buildExpandableSection(
                          'About Seller',
                          Icons.add,
                          onTap: () {
                            final sellerId = details?.sellerProfileId;
                            if (sellerId == null || sellerId == 0) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SellerProfileScreen(sellerId: sellerId),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 28),

                      // You may also like
                      Text(
                        'You may also like',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildRelatedProducts(details?.suggestions ?? const []),

                      const SizedBox(height: 200), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top navigation bar
          _buildTopBar(context),

          // Bottom action bar
          _buildBottomActionBar(context, priceLabel),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = context.appColors;
    final navigator = Navigator.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderIconButton(
              asset: AppIcons.back,
              iconColor: colors.textPrimary,
              onTap: () {
                if (navigator.canPop()) {
                  navigator.pop();
                  return;
                }
                navigator.pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
            ),
            Row(
              children: [
                HeaderIconButton(
                  asset: AppIcons.notification,
                  iconColor: colors.textPrimary,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                const SizedBox(width: 8),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  iconColor: colors.textPrimary,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(String? imageUrl) {
    return Container(
      height: 300,
      margin: const EdgeInsets.fromLTRB(16, 83, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.appColors.surfaceSecondary,
        image: (imageUrl == null)
            ? null
            : DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: imageUrl == null
          ? Center(
              child: Icon(
                Icons.image,
                size: 80,
                color: context.appColors.textTertiary,
              ),
            )
          : null,
    );
  }

  Widget _buildImageIndicators() {
    // Only one image is supported currently; hide indicators to avoid confusing UX.
    return const SizedBox.shrink();
  }

  Widget _buildSizeSelector(String? backendSizes) {
    final colors = context.appColors;
    final parsed = (backendSizes ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final sizes = parsed.isNotEmpty ? parsed : ['XS', 'S', 'M', 'L', 'XL'];

    if (!sizes.contains(selectedSize)) {
      selectedSize = sizes.first;
    }

    return Row(
      children: sizes.map((size) {
        final isSelected = selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => selectedSize = size),
          child: Container(
            width: 44,
            height: 34,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? colors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? colors.accent : colors.border,
              ),
            ),
            child: Center(
              child: Text(
                size,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? colors.onAccent : colors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessingInfo(String priceLabel) {
    final colors = context.appColors;
    final details = ref
        .read(productDetailsProvider(widget.productId))
        .maybeWhen(data: (d) => d, orElse: () => null);

    final days = details?.processingDays;
    final type = details?.processingTimeType ?? 'normal';
    final duration = days == null ? 'Contact seller' : '$days days';
    final typeLabel = type == 'quick_quick' ? 'Quick Quick' : 'Normal';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        color: colors.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            priceLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Icon(icon, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection({
    required int reviewCount,
    required String avgRating,
    required String user,
    required String date,
    required String headline,
    required String body,
    required VoidCallback onMore,
  }) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews ($reviewCount)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        avgRating,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFDB80),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Far-right "More" action
              GestureDetector(
                onTap: onMore,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (reviewCount > 0) ...[
            const SizedBox(height: 16),
            // Inline: just the top 1 review
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return const Icon(
                      Icons.star,
                      size: 11,
                      color: Color(0xFFFFDB80),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  headline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(List<Map<String, dynamic>> suggestions) {
    num? parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    final products = suggestions.take(2).map((s) {
      return Product(
        id: ((s['id'] as num?)?.toInt() ?? 0).toString(),
        title: (s['name'] as String?) ?? '',
        priceLabel: formatPrice(parseNum(s['price'])),
        rating: 0,
        reviewCount: 0,
        imageUrl: (s['image'] as String?),
        imageColor: 0xFFD9D9D9,
      );
    }).toList();

    if (products.isEmpty) {
      return const SizedBox(height: 240);
    }

    return _buildRelatedList(products);
  }

  Widget _buildRelatedList(List<Product> products) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            width: 168,
            product: product,
            onTap: () {
              final id = int.tryParse(product.id);
              if (id == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(productId: id),
                ),
              );
            },
            onFavoriteTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, String priceLabel) {
    final colors = context.appColors;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Quantity selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                      child: Icon(
                        Icons.remove,
                        color: colors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => setState(() => quantity++),
                      child: Icon(
                        Icons.add,
                        color: colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to bag button (tap area)
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    // Use the processing time type from the product details
                    final details = ref
                        .read(productDetailsProvider(widget.productId))
                        .value;
                    final processingTimeType =
                        details?.processingTimeType ?? 'normal';

                    try {
                      await ref
                          .read(cartActionsProvider.notifier)
                          .addItem(
                            productId: widget.productId,
                            quantity: quantity,
                            selectedSize: selectedSize,
                            processingTimeType: processingTimeType,
                          );

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                      Navigator.of(context).pushNamed(AppRoutes.cart);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add to cart')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Add to Bag',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    priceLabel,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'Delivery calculated at checkout',
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  // lightweight formatting: "Aug 19, 2023"
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final m = months[(dt.month - 1).clamp(0, 11)];
  return '$m ${dt.day}, ${dt.year}';
}
