// order_details_screen.dart
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            // Header with buttons and title
            Container(
              height: 104,
              padding: const EdgeInsets.only(top: 32),
              child: Stack(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildIconButton(Icons.arrow_back),
                    ),
                  ),
                  
                  // Title
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                      ),
                    ),
                  ),
                  
                  // Right button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildIconButton(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Order Information section
                    _buildOrderInformation(),
                    
                    const SizedBox(height: 16),
                    
                    // Shipping Address section
                    _buildShippingAddress(),
                    
                    const SizedBox(height: 16),
                    
                    // Items in Order section
                    _buildItemsInOrder(),
                    
                    const SizedBox(height: 16),
                    
                    // Payment section
                    _buildPaymentDetails(),
                    
                    // Bottom spacing for buttons
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            
            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF603814),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  // Buy Again button
                  Expanded(
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDAF40)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: Text(
                              'Buy Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFDAF40),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Track button
                  Expanded(
                    child: Container(
                      height: 57,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDAF40),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFDAF40).withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Text(
                              'Track',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFBF5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildOrderInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ordered on
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ordered on',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF777F84),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mar 03, 2022  05:49:40',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Order Number with Copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Number',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF777F84),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#rt667899hnny007',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ],
              ),
              
              // Copy button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Copy',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF777F84),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Shipping Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipping Time',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF777F84),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '10-12 business days\nfrom shipped',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping to',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '08102718764\nRoyal Anchor, Abuja, FCT, \nNigeria 900187',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C4042),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsInOrder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items in Order',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Item 1
          _buildOrderItem(
            productName: 'Agagbada in Vogue',
            price: 'From N20,000',
            size: 'Small',
            quantity: 'X1',
          ),
          
          const SizedBox(height: 20),
          
          // Item 2
          _buildOrderItem(
            productName: 'Agagbada in Vogue',
            price: 'From N20,000',
            size: 'Small',
            quantity: 'X1',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String productName,
    required String price,
    required String size,
    required String quantity,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        Container(
          width: 80,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Product details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0F1011),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ],
          ),
        ),
        
        // Size and quantity
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              size,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C4042),
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              quantity,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C4042),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment Methods
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                'Pay with Card',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Payment Details
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C4042),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Breakdown
          Column(
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                  Text(
                    'N40,000',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Shipping
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shipping',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                  Text(
                    'N4,000',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                  Text(
                    'N44,000',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}