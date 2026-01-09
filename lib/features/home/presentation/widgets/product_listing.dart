// product_listing_screen.dart
import 'package:flutter/material.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/sort_sheet.dart';

import '../../../product/data/mock_products.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product_detail/presentation/product_detail_screen.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/filter_sheet.dart';

class ProductListingScreen extends StatelessWidget {
  const ProductListingScreen({
    super.key,
    required this.pageTitle,
    this.breadcrumb,
    this.showBusinessTypeFilter = false,
  });

  final String pageTitle;
  final String? breadcrumb;
  final bool showBusinessTypeFilter;

  @override
  Widget build(BuildContext context) {
    // Example usage:
    // Open the sort overlay
    void openSortOverlay() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) => SortOverlay(
          searchQuery: 'men', // Optional
          initialSort: 'most_recent',
          onApplySort: (selectedSort) {
            print('Applied sort: $selectedSort');
            // Apply the selected sort
          },
          onClearSort: () {
            print('Sort cleared');
            // Clear sort settings
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #FFF8F1
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            _AppHeader(title: pageTitle, subtitle: breadcrumb),
            const SizedBox(height: 16),

            // Sort & Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FilterButton(
                    icon: Icons.sort,
                    label: 'Sort',
                    onTap: openSortOverlay,
                  ),
                  _FilterButton(
                    icon: Icons.filter_list,
                    label: 'Filters',
                    onTap: () {
                      showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.transparent,
                        builder: (_) => FilterSheet(
                          showBusinessType: showBusinessTypeFilter,
                          initialFilters: const {
                            'location': 'Ghana',
                            'businessType': 'Freelancer',
                            'reviewRange': '5-4',
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Products grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.62,
                ),
                itemCount: mockProducts.length,
                itemBuilder: (context, index) {
                  final product = mockProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductDetailsScreen(),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      // TODO: Wire wishlist persistence later.
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// App Header Widget
class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // border: Border.all(color: const Color(0xFFCCCCCC)), // #CCCCCC
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDEDEDE)),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 16,
                  color: Color(0xFF241508),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 10,
                    color: Color(0xFF777F84),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),

          // Spacer to balance layout
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF241508)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 14,
                color: Color(0xFF241508),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

