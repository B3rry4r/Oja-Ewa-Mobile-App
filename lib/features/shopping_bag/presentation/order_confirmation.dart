import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDEDEDE)),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Order confirmation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer to balance the title
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Address section
                    _buildAddressSection(),

                    const SizedBox(height: 32),

                    // Payment Method section
                    _buildPaymentMethodSection(),

                    const SizedBox(height: 32),

                    // Items section
                    _buildItemsSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom order summary
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2021),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Sanusi Sulat 08102718764\nRoyal Anchor, Abuja, FCT, \nNigeria 900187',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3C4042),
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2021),
          ),
        ),
        const SizedBox(height: 12),

        // Pay with cards option (selected)
        Container(
          height: 88,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFA15E22),
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFA15E22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Pay with cards',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E2021),
                ),
              ),
              const Spacer(),
              // Card logos
              Row(
                children: [
                  // Mastercard logo placeholder
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Visa logo placeholder
                  Container(
                    width: 20,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pay with Bank Transfer option (not selected)
        Container(
          height: 64,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            children: [
              // Radio button (empty)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF777F84),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Pay with Bank Transfer',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E2021),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2021),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildItemCard('1'),
            const SizedBox(width: 12),
            _buildItemCard('2'),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(String quantity) {
    return Container(
      width: 80,
      height: 98,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Product image placeholder
          const Center(
            child: Icon(
              Icons.image,
              size: 40,
              color: Colors.white54,
            ),
          ),
          // Quantity badge
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F1).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E2021),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF603814),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              // Order Summary title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFBFBFB),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Subtotal
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                  Text(
                    'N40,000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Delivery
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                  Text(
                    'N4,000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Divider
              Container(
                height: 1,
                color: const Color(0xFFFBFBFB).withOpacity(0.2),
              ),

              const SizedBox(height: 24),

              // Total
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                  Text(
                    'N44,000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Place Order button
              GestureDetector(
                onTap: () {
                  // Handle place order
                },
                child: Container(
                  width: double.infinity,
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
                      'Place Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFBF5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}