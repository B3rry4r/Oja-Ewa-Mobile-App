import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/shopping_bag/presentation/widgets/size_selection_bottom_sheet.dart';
import 'package:ojaewa/app/router/app_router.dart';

class ShoppingBagScreen extends StatefulWidget {
  const ShoppingBagScreen({super.key});

  @override
  State<ShoppingBagScreen> createState() => _ShoppingBagScreenState();
}

class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
  final List<BagItem> bagItems = [
    BagItem(name: 'Agbada in Voue', size: 'XS', price: 20000, quantity: 1),
    BagItem(name: 'Agbada in Voue', size: 'XS', price: 20000, quantity: 1),
  ];

  int get totalPrice =>
      bagItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(iconColor: Colors.white, showActions: false),

            // Main content card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // My Bag title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      child: Text(
                        'My Bag',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bag items list
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bagItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildBagItem(bagItems[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom checkout section
            _buildCheckoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBagItem(BagItem item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 122,
            height: 152,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: AppImagePlaceholder(
                width: 96,
                height: 96,
                borderRadius: 0,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and favorite button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Color(0xFF241508),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Size selector
                GestureDetector(
                  onTap: () async {
                    final selected = await SizeSelectionBottomSheet.show(
                      context,
                      initialSize: item.size,
                    );
                    if (selected != null && selected != item.size) {
                      setState(() {
                        bagItems[index] = item.copyWith(size: selected);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCCCCCC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.size,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E2021),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Color(0xFF1E2021),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 31),

                // Price and quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'N${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                      ),
                    ),
                    // Quantity selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (item.quantity > 1) {
                                setState(() {
                                  item.quantity--;
                                });
                              }
                            },
                            child: const Icon(
                              Icons.remove,
                              size: 20,
                              color: Color(0xFF3C4042),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C4042),
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                item.quantity++;
                              });
                            },
                            child: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF3C4042),
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

  Widget _buildCheckoutSection() {
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
              const SizedBox(height: 16),

              // Subtotal row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                  Text(
                    'N${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Delivery fee note
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Delivery fee not included yet',
                  style: TextStyle(fontSize: 12, color: Color(0xFFFBFBFB)),
                ),
              ),

              const SizedBox(height: 20),

              // Checkout button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.orderConfirmation);
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
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFBF5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class BagItem {
  String name;
  String size;
  int price;
  int quantity;

  BagItem({
    required this.name,
    required this.size,
    required this.price,
    required this.quantity,
  });

  BagItem copyWith({String? name, String? size, int? price, int? quantity}) {
    return BagItem(
      name: name ?? this.name,
      size: size ?? this.size,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
