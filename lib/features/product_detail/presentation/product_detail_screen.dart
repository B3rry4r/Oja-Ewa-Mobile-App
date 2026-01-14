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
import 'package:ojaewa/features/product_detail/presentation/reviews.dart';
import 'package:ojaewa/features/product_detail/presentation/seller_profile.dart';

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
            child: Text(
              'Failed to load product',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
      data: (details) {
        final title = details.name;
        final by = details.sellerBusinessName == null ? '' : 'by ${details.sellerBusinessName}';

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8F1),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(details.image),
                    const SizedBox(height: 13),
                    _buildImageIndicators(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
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
                                  border: Border.all(color: const Color(0xFFDEDEDE)),
                                ),
                                child: const Icon(Icons.favorite_border, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (by.isNotEmpty)
                            Text(
                              by,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF777F84),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            details.price?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF241508),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if ((details.description ?? '').trim().isNotEmpty)
                            Text(
                              details.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1E2021),
                                height: 1.4,
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Existing sections below remain UI-only; can be further wired later.
                          ReviewsScreen(),
                          const SizedBox(height: 24),
                          SellerProfileScreen(),

                          const SizedBox(height: 24),

                          if (details.suggestions.isNotEmpty) ...[
                            const Text(
                              'You may also like',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF241508),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSuggestions(details.suggestions),
                          ],

                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Top header buttons
              Positioned(
                top: 56,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeaderIconButton(
                      asset: AppIcons.back,
                      iconColor: Colors.white,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      children: [
                        HeaderIconButton(
                          asset: AppIcons.notification,
                          iconColor: Colors.white,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                        ),
                        const SizedBox(width: 8),
                        HeaderIconButton(
                          asset: AppIcons.bag,
                          iconColor: Colors.white,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom bar placeholder retains existing behavior (info sheet)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageCarousel(String? imageUrl) {
    // Existing UI is placeholder-based; keep layout.
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

  Widget _buildSuggestions(List<Map<String, dynamic>> suggestions) {
    final products = suggestions.map((s) {
      final seller = s['seller_profile'];
      final title = (s['name'] as String?) ?? '';
      final price = s['price']?.toString() ?? '';
      return Product(
        id: (s['id'] as num?)?.toInt().toString() ?? '',
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

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFDEDEDE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(cartActionsProvider.notifier).addItem(productId: widget.productId, quantity: 1);
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamed(AppRoutes.shoppingBag);
                  } catch (_) {
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => InfoBottomSheet(
                        title: 'Could not add to bag',
                        content: const Text('Please try again.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA15E22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add to bag'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
