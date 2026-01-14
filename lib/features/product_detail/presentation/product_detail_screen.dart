import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/info_bottom_sheet.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product/presentation/controllers/product_details_controller.dart';
import 'package:ojaewa/features/product_detail/presentation/seller_profile.dart';
import 'package:ojaewa/features/product_detail/presentation/reviews.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailsScreen> {
  String selectedSize = 'S';
  String selectedProcessing = 'Normal';
  int quantity = 1;
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Do not change layout; only populate data.
    final details = ref.watch(productDetailsProvider(widget.productId)).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );

    final reviewsPage = ref.watch(reviewsProvider((type: 'product', id: widget.productId))).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );

    final firstReview = (reviewsPage?.items.isNotEmpty ?? false) ? reviewsPage!.items.first : null;

    final productTitle = (details?.name ?? '').trim();
    final sellerName = (details?.sellerBusinessName ?? '').trim();
    final imageUrl = (details?.image ?? '').trim();
    final priceLabel = details?.price?.toString() ?? 'N20,000';

    final reviewCount = reviewsPage?.total ?? 4;
    final avgRating = reviewsPage?.entity.avgRating?.toString() ?? '4.0';

    // keep original hardcoded as fallback
    final reviewUser = (firstReview?.user?.displayName ?? 'Lennox Len');
    final reviewDate = firstReview?.createdAt == null ? 'Aug 19, 2023' : _formatDate(firstReview!.createdAt!);
    final reviewHeadline = (firstReview?.headline ?? 'So good');
    final reviewBody = (firstReview?.body ??
            'Good customer service, I was at the Spa some times back, the receptionist is ok and their agents are so goos aat what they do. Will use them again')
        .trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
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
                            productTitle.isEmpty ? 'Agbada in Voue' : productTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF241508),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDEDEDE),
                              ),
                            ),
                            child: const Icon(Icons.favorite_border, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'by ${sellerName.isEmpty ? 'Jenny Stitches' : sellerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF595F63),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Size selection
                      const Text(
                        'Size',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E2021),
                        ),
                      ),

                      const SizedBox(height: 5),

                      _buildSizeSelector(details?.size),

                      const SizedBox(height: 8),

                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'View Size Chart',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF777F84),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Processing time section
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processing Time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E2021),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Select your package type',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777F84),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildProcessingOptions(priceLabel),

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
                              (details?.description ?? 'No description provided'),
                              style: const TextStyle(
                                fontFamily: 'Campton',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3C4042),
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
                          arguments: {'type': 'product', 'id': widget.productId},
                        ),
                      ),

                      _buildExpandableSection(
                        'About Seller',
                        Icons.add,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SellerProfileScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // You may also like
                      const Text(
                        'You may also like',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF241508),
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
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 104,
        color: const Color(0xFFFFF8F1),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderIconButton(
              asset: AppIcons.back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            Row(
              children: [
                HeaderIconButton(
                  asset: AppIcons.notification,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                const SizedBox(width: 8),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
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
        color: const Color(0xFFD9D9D9),
        image: (imageUrl == null)
            ? null
            : DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
      ),
      child: imageUrl == null
          ? const Center(child: Icon(Icons.image, size: 80, color: Colors.white54))
          : null,
    );
  }

  Widget _buildImageIndicators() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentImageIndex ? const Color(0xFFFDAF40) : Colors.transparent,
              border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSizeSelector(String? backendSizes) {
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
              color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFFA15E22) : const Color(0xFFCCCCCC),
              ),
            ),
            child: Center(
              child: Text(
                size,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFFFBFBFB) : const Color(0xFF1E2021),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessingOptions(String priceLabel) {
    return Row(
      children: [
        Expanded(
          child: _buildProcessingCard(
            'Normal',
            '10 days',
            priceLabel,
            isSelected: selectedProcessing == 'Normal',
            onTap: () => setState(() => selectedProcessing = 'Normal'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildProcessingCard(
            'Quick Quick',
            '10 days',
            priceLabel,
            isSelected: selectedProcessing == 'Quick Quick',
            onTap: () => setState(() => selectedProcessing = 'Quick Quick'),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingCard(
    String title,
    String duration,
    String price, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF603814) : const Color(0xFFDEDEDE),
          ),
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
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2021),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(duration, style: const TextStyle(fontSize: 12, color: Color(0xFF777F84))),
                    const SizedBox(height: 12),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F1011),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF603814) : const Color(0xFF777F84),
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.circle, size: 14, color: Color(0xFF603814))
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2021),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        avgRating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2021),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    'More',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Inline: just the top 1 review
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user, style: const TextStyle(fontSize: 12, color: Color(0xFF3C4042))),
                  Text(date, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return const Icon(Icons.star, size: 11, color: Color(0xFFFFDB80));
                }),
              ),
              const SizedBox(height: 12),
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E2021),
                ),
              ),
              const SizedBox(height: 8),
              Text(body, style: const TextStyle(fontSize: 14, color: Color(0xFF1E2021))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(List<Map<String, dynamic>> suggestions) {
    final products = suggestions.take(2).map((s) {
      return Product(
        id: ((s['id'] as num?)?.toInt() ?? 0).toString(),
        title: (s['name'] as String?) ?? 'Agbada in Voue',
        priceLabel: 'From ${(s['price']?.toString() ?? 'N20,000')}',
        rating: 4.0,
        reviewCount: 8,
        imageColor: 0xFFD9D9D9,
      );
    }).toList();

    if (products.isEmpty) {
      const fallback = [
        Product(
          id: 'related1',
          title: 'Agbada in Voue',
          priceLabel: 'From N20,000',
          rating: 4.0,
          reviewCount: 8,
          imageColor: 0xFFD9D9D9,
        ),
        Product(
          id: 'related2',
          title: 'Agbada in Voue',
          priceLabel: 'From N20,000',
          rating: 4.0,
          reviewCount: 8,
          imageColor: 0xFFF5E0CE,
        ),
      ];
      return _buildRelatedList(fallback);
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
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)),
              );
            },
            onFavoriteTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, String priceLabel) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF603814),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Quantity selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFBFBFB)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                      child: const Icon(Icons.remove, color: Color(0xFFFBFBFB), size: 20),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFBFBFB),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => setState(() => quantity++),
                      child: const Icon(Icons.add, color: Color(0xFFFBFBFB), size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to bag button (tap area)
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final processingTimeType = selectedProcessing.toLowerCase().contains('quick') ||
                            selectedProcessing.toLowerCase().contains('express')
                        ? 'express'
                        : 'normal';

                    await ref.read(cartActionsProvider.notifier).addItem(
                          productId: widget.productId,
                          quantity: quantity,
                          selectedSize: selectedSize,
                          processingTimeType: processingTimeType,
                        );
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamed(AppRoutes.shoppingBag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDAF40),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFDAF40).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Add to Bag',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFBF5),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                  Text(
                    '#25,000',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFFE9E9E9).withOpacity(0.6),
                      decoration: TextDecoration.lineThrough,
                    ),
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
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final m = months[(dt.month - 1).clamp(0, 11)];
  return '$m ${dt.day}, ${dt.year}';
}
