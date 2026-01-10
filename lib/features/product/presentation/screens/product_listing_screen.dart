import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/filter_sheet.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/sort_sheet.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';

/// Women's Catalog Screen - Product browsing interface with categories and filters
class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({
    super.key,
    required this.pageTitle,
    required this.breadcrumb,
    required this.showBusinessTypeFilter,
    this.onProductTap,
  });

  final String pageTitle;
  final String breadcrumb;
  final bool showBusinessTypeFilter;

  /// Allows callers to override what happens when a product is tapped.
  /// If null, defaults to navigating to Product Details.
  final void Function(BuildContext context)? onProductTap;

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Main Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Text(
                          widget.pageTitle,
                          style: const TextStyle(
                            fontSize: 33,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                            height: 1.2,
                          ),
                        ),
                      ),

                      // Breadcrumb
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.breadcrumb,
                          style: const TextStyle(
                            color: Color(0xFF777F84),
                            fontSize: 14,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Category Pills
                      _buildCategoryPills(),

                      const SizedBox(height: 16),

                      // Sort and Filter Buttons
                      _buildSortFilterButtons(),

                      const SizedBox(height: 24),

                      // Product Grid
                      _buildProductGrid(),

                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return const AppHeader(iconColor: Colors.white);
  }

  Widget _buildCategoryPills() {
    final categories = ['All', 'Dress', 'Skirts and Blouse', 'Blouses'];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFCCCCCC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFFFBFBFB)
                        : const Color(0xFF301C0A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Sort Button
          _buildActionButton(
            iconAsset: AppIcons.sort,
            label: 'Sort',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SortOverlay(),
              );
            },
          ),

          const Spacer(),

          // Filter Button
          _buildActionButton(
            iconAsset: AppIcons.filter,
            label: 'Filters',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FilterSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF241508),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First Row
          Row(
            children: [
              Expanded(
                child: _buildProductCard(
                  title: 'Light Blue Shirt Dress',
                  price: '₦ 35,000.00',
                  originalPrice: '₦ 55,000.00',
                  rating: 4.0,
                  reviews: 8,
                  imageColor: const Color(0xFFD9D9D9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProductCard(
                  title: 'Two Piece Set',
                  price: '₦ 35,000.00',
                  originalPrice: '₦ 55,000.00',
                  rating: 4.0,
                  reviews: 8,
                  imageColor: const Color(0xFFD9D9D9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildProductCard(
                  title: 'Light Blue Shirt Dress',
                  price: '₦ 35,000.00',
                  originalPrice: '₦ 55,000.00',
                  rating: 4.0,
                  reviews: 8,
                  imageColor: const Color(0xFFD9D9D9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProductCard(
                  title: 'Two Piece Set',
                  price: '₦ 35,000.00',
                  originalPrice: '₦ 55,000.00',
                  rating: 4.0,
                  reviews: 8,
                  imageColor: const Color(0xFFD9D9D9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String originalPrice,
    required double rating,
    required int reviews,
    required Color imageColor,
  }) {
    final product = Product(
      id: title,
      title: title,
      priceLabel: price,
      rating: rating,
      reviewCount: reviews,
      imageColor: imageColor.value,
    );

    return ProductCard(
      product: product,
      onTap: () {
        final handler = widget.onProductTap;
        if (handler != null) {
          handler(context);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductDetailsScreen()),
          );
        }
      },
      onFavoriteTap: () {},
    );
  }
}
