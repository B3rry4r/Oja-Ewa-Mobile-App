// File: shopping_bag_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class ShoppingBagScreen extends StatelessWidget {
  const ShoppingBagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814), // Main background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(
              iconColor: Colors.white,
            ),

            const SizedBox(height: 24),

            // Main content card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F1), // Cream background
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "My Bag" title
                  const Padding(
                    padding: EdgeInsets.fromLTRB(17, 16, 16, 16),
                    child: Text(
                      'My Bag',
                      style: TextStyle(
                        fontFamily: 'Campton',
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        letterSpacing: -1,
                        height: 1.2,
                      ),
                    ),
                  ),

                  // First product item
                  _buildProductItem(
                    productName: 'Agbada in Voue',
                    price: 'N20,000',
                    quantity: 1,
                    size: 'XS',
                    isFirstItem: true,
                  ),

                  // Second product item
                  _buildProductItem(
                    productName: 'Agbada in Voue',
                    price: 'N20,000',
                    quantity: 1,
                    size: 'XS',
                    isFirstItem: false,
                  ),

                  // Summary section
                  _buildSummarySection(),

                  // Checkout button section
                  _buildCheckoutSection(),
                ],
              ),
            ),

            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Product item widget
  Widget _buildProductItem({
    required String productName,
    required String price,
    required int quantity,
    required String size,
    required bool isFirstItem,
  }) {
    return Container(
      margin: EdgeInsets.only(
        top: isFirstItem ? 0 : 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE), width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: 122,
            height: 152,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            // In a real app, this would be an actual image
            child:
                const Placeholder(), // Replace with Image.network or AssetImage
          ),

          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        productName,
                        style: const TextStyle(
                          fontFamily: 'Campton',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF241508),
                          height: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Delete button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFDEDEDE),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {},
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Size selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFCCCCCC),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        size,
                        style: const TextStyle(
                          fontFamily: 'Campton',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E2021),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Price and quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: 'Campton',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        height: 1.2,
                      ),
                    ),

                    // Quantity selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFDEDEDE),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          // Minus button
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Quantity
                          Text(
                            quantity.toString(),
                            style: const TextStyle(
                              fontFamily: 'Campton',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C4042),
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Plus button
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Summary section widget
  Widget _buildSummarySection() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF603814), // Dark brown background
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Subtotal row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFBFBFB),
                  height: 1.2,
                ),
              ),
              Text(
                'N40,000',
                style: const TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFBFBFB),
                  height: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Delivery disclaimer
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delivery fee not included yet',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFFFBFBFB),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Checkout section widget
  Widget _buildCheckoutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        elevation: 8,
        shadowColor: const Color(0xFFFDAF40).withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFFDaf40), // Orange button color
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              // Handle checkout
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFBF5), // Off-white text
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
