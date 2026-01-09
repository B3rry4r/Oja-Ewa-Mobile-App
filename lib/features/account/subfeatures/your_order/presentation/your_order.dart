// orders_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFF8F1),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'Your Orders',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),

            // Filter tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // All orders (active)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA15E22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'All orders',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFBFBFB),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Processing
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCCCCCC)),
                    ),
                    child: const Text(
                      'Processing',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF301C0A),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Shipped
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCCCCCC)),
                    ),
                    child: const Text(
                      'Shipped',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF301C0A),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Delivered
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCCCCCC)),
                    ),
                    child: const Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF301C0A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orders list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Order 1 - Delivered
                    _buildOrderCard(
                      context,
                      orderId: 'Order #wgtyhkihtb556hhg',
                      status: 'Delivered',
                      statusColor: const Color(0xFF70B673),
                      itemCount: '2 items',
                      totalAmount: 'N40,000',
                      hasReviewButton: true,
                    ),

                    const SizedBox(height: 16),

                    // Order 2 - Processing
                    _buildOrderCard(
                      context,
                      orderId: 'Order #wgtyhkihtb556hhg',
                      status: 'Processing',
                      statusColor: const Color(0xFF3095CE),
                      itemCount: '2 items',
                      totalAmount: 'N40,000',
                      hasReviewButton: false,
                    ),

                    const SizedBox(height: 16),

                    // Order 3 - Shipped
                    _buildOrderCard(
                      context,
                      orderId: 'Order #wgtyhkihtb556hhg',
                      status: 'Shipped',
                      statusColor: const Color(0xFF3095CE),
                      itemCount: '2 items',
                      totalAmount: 'N40,000',
                      hasReviewButton: false,
                    ),

                    const SizedBox(height: 16),

                    // Order 4 - Cancelled
                    _buildOrderCard(
                      context,
                      orderId: 'Order #wgtyhkihtb556hhg',
                      status: 'Cancelled',
                      statusColor: const Color(0xFFCCCCCC),
                      itemCount: '2 items',
                      totalAmount: 'N40,000',
                      hasReviewButton: false,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId,
    required String status,
    required Color statusColor,
    required String itemCount,
    required String totalAmount,
    required bool hasReviewButton,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.orderDetails),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Order header with ID and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Product images
          Row(
            children: [
              Container(
                width: 80,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 79,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Order summary and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemCount,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF595F63),
                    ),
                  ),
                  Text(
                    'Total: $totalAmount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF595F63),
                    ),
                  ),
                ],
              ),

              // Action buttons
              Row(
                children: [
                  if (hasReviewButton) ...[
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.reviewSubmission),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 33,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDAF40)),
                        ),
                        child: Center(
                          child: Text(
                            'Review',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFDAF40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Buy Again button
                  Container(
                    height: 33,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDAF40)),
                    ),
                    child: Center(
                      child: Text(
                        'Buy Again',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFDAF40),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Track button
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.trackingOrder),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 33,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDAF40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Track',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFFFBF5),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ],
      ),
    ),
   );
  }
}
