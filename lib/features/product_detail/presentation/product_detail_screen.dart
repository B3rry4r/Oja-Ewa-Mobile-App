import 'package:flutter/material.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/product/domain/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'S';
  String selectedProcessing = 'Normal';
  int quantity = 1;
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                _buildImageCarousel(),

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
                          const Text(
                            'Agbada in Voue',
                            style: TextStyle(
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

                      const Text(
                        'by Jenny Stitches',
                        style: TextStyle(
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
                      _buildExpandableSection('Description', Icons.add),
                      _buildExpandableSection('Return Policy', Icons.add),
                      _buildReviewsSection(),
                      _buildExpandableSection('About Seller', Icons.add),

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

                      _buildRelatedProducts(),

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
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
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
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                const SizedBox(width: 8),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      margin: const EdgeInsets.fromLTRB(16, 83, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFD9D9D9),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 80, color: Colors.white54),
      ),
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
              color: index == currentImageIndex
                  ? const Color(0xFFFDAF40)
                  : Colors.transparent,
              border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSizeSelector() {
    final sizes = ['XS', 'S', 'M', 'L', 'XL'];

    return Row(
      children: sizes.map((size) {
        final isSelected = size == selectedSize;
        return GestureDetector(
          onTap: () => setState(() => selectedSize = size),
          child: Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : const Color(0xFFCCCCCC),
              ),
            ),
            child: Center(
              child: Text(
                size,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? const Color(0xFFFBFBFB)
                      : const Color(0xFF1E2021),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessingOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildProcessingCard(
            'Normal',
            '10 days',
            'N20,000',
            isSelected: selectedProcessing == 'Normal',
            onTap: () => setState(() => selectedProcessing = 'Normal'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildProcessingCard(
            'Quick Quick',
            '10 days',
            'N20,000',
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
        height: 122,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5E0CE) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF603814)
                : const Color(0xFFCCCCCC),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 25,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDAF40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E2021),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              duration,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0F1011)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F1011),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF603814)
                          : const Color(0xFF777F84),
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.circle,
                          size: 14,
                          color: Color(0xFF603814),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, IconData icon) {
    return Container(
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
    );
  }

  Widget _buildReviewsSection() {
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
                  const Text(
                    'Reviews (4)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '4.0',
                        style: TextStyle(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.keyboard_arrow_down, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sample review
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lennox Len',
                    style: TextStyle(fontSize: 12, color: Color(0xFF3C4042)),
                  ),
                  Text(
                    'Aug 19, 2023',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
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
              const Text(
                'So good',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E2021),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Good customer service, I was at the Spa some times back, the receptionist is ok and their agents are so goos aat what they do. Will use them again',
                style: TextStyle(fontSize: 14, color: Color(0xFF1E2021)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    // Using the shared ProductCard extracted from this design.
    const products = [
      // TODO: Replace with API-driven related products.
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

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {},
            onFavoriteTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar() {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
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
                      child: const Icon(
                        Icons.remove,
                        color: Color(0xFFFBFBFB),
                        size: 20,
                      ),
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
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFFBFBFB),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to bag button
              Expanded(
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
              const SizedBox(width: 16),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'N20,000',
                    style: TextStyle(
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
