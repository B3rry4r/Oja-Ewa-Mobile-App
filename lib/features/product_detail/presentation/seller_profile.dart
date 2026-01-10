import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/product/domain/product.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(
              iconColor: Colors.white,
            ),

            // Main content card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Seller name
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Jenny Stitches',
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(21),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA15E22),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Selling since
                            _buildStatColumn(
                              label: 'Selling since',
                              value: '3 years ago',
                              textColor: const Color(0xFFFBFBFB),
                            ),

                            // Total Sales
                            _buildStatColumn(
                              label: 'Total Sales',
                              value: '200+',
                              textColor: const Color(0xFFFFFFFF),
                            ),

                            // Average Rating
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ave. Rating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFBFBFB),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '4.8 (150)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFBFBFB),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Star rating
                                Row(
                                  children: List.generate(5, (index) {
                                    return const Icon(
                                      Icons.star,
                                      size: 11,
                                      color: Color(0xFFFFDB80),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Products section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Products grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            const product = Product(
                              id: 'sellerProduct',
                              title: 'Agbada in Voue',
                              priceLabel: 'From N20,000',
                              rating: 4.0,
                              reviewCount: 8,
                              imageColor: 0xFFD9D9D9,
                            );

                            return ProductCard(
                              width: 168,
                              product: product,
                              onTap: () {},
                              onFavoriteTap: () {},
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

}