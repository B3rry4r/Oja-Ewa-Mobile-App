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

/// Restored UI (original layout) + minimal API wiring.
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
    final detailsAsync = ref.watch(productDetailsProvider(widget.productId));

    return detailsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFFF8F1),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFFFF8F1),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load product', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ),
      data: (details) {
        final title = details.name;
        final seller = details.sellerBusinessName;
        final byLine = (seller == null || seller.trim().isEmpty) ? '' : 'by $seller';

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
                    _buildImageCarousel(details.image),

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
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF241508),
                                  ),
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

                          if (byLine.isNotEmpty)
                            Text(
                              byLine,
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

                          _buildSizeSelector(),

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

                          _buildProcessingOptions(),

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
                                  (details.description ?? 'No description provided'),
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
                            onTap: () {
                              InfoBottomSheet.show(
                                context,
                                title: 'Return Policy',
                                content: const Text(
                                  'Returns are accepted within the stated return window.\n'
                                  'Items must be unused and in original condition.\n'
                                  'Contact support to initiate a return.',
                                  style: TextStyle(
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
                          _buildReviewsSection(details.id),
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

                          _buildRelatedProducts(details.suggestions),

                          const SizedBox(height: 200), // Space for bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Top navigation bar
              _buildTopBar(),

              // Bottom action bar
              _buildBottomActionBar(details.price?.toString() ?? ''),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
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

  Widget _buildBottomActionBar(String priceLabel) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F1),
          border: Border(
            top: BorderSide(color: Color(0xFFDEDEDE)),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF777F84),
                  ),
                ),
                Text(
                  priceLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF241508),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref.read(cartActionsProvider.notifier).addItem(productId: widget.productId, quantity: 1);
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamed(AppRoutes.shoppingBag);
                    } catch (_) {
                      if (!context.mounted) return;
                      InfoBottomSheet.show(
                        context,
                        title: 'Could not add to bag',
                        content: const Text('Please try again.'),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA15E22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(String? imageUrl) {
    return Container(
      height: 358,
      color: const Color(0xFFD9D9D9),
      alignment: Alignment.center,
      child: imageUrl == null
          ? const Icon(Icons.image, size: 72, color: Colors.white)
          : Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
    );
  }

  Widget _buildImageIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == currentImageIndex;
          return Container(
            width: isActive ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFA15E22) : const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSizeSelector() {
    final sizes = ['S', 'M', 'L', 'XL', 'XXL'];
    return Row(
      children: sizes.map((size) {
        final isSelected = selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => selectedSize = size),
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF241508) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDEDEDE)),
            ),
            child: Center(
              child: Text(
                size,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFFFFFBF5) : const Color(0xFF241508),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessingOptions() {
    final options = ['Normal', 'Express'];
    return Row(
      children: options.map((opt) {
        final isSelected = selectedProcessing == opt;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedProcessing = opt),
            child: Container(
              height: 56,
              margin: EdgeInsets.only(right: opt == 'Normal' ? 8 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? const Color(0xFF241508) : const Color(0xFFDEDEDE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF241508)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt == 'Normal' ? '5-7 days' : '2-3 days',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF777F84)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpandableSection(String title, IconData icon, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDEDEDE)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E2021)),
              ),
              Icon(icon, size: 20, color: const Color(0xFF777F84)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(int productId) {
    return _buildExpandableSection(
      'Reviews',
      Icons.add,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ReviewsScreen(),
          settings: RouteSettings(arguments: {'type': 'product', 'id': productId}),
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(List<Map<String, dynamic>> suggestions) {
    if (suggestions.isEmpty) {
      return const SizedBox(height: 180);
    }

    final products = suggestions.map((s) {
      final title = (s['name'] as String?) ?? '';
      final price = s['price']?.toString() ?? '';
      return Product(
        id: ((s['id'] as num?)?.toInt() ?? 0).toString(),
        title: title,
        priceLabel: price,
        rating: 0,
        reviewCount: 0,
        imageColor: 0xFFD9D9D9,
      );
    }).toList();

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return ProductCard(
            width: 180,
            product: p,
            onTap: () {
              final id = int.tryParse(p.id);
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
}
