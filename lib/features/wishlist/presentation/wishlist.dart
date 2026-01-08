// wishlist_screen.dart
import 'package:flutter/material.dart';

import '../../product/data/mock_products.dart';
import '../../product/presentation/widgets/product_card.dart';
import '../../product_detail/presentation/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onKeepShoppingPressed;

  const WishlistScreen({
    super.key,
    this.onBackPressed,
    this.onFilterPressed,
    this.onSettingsPressed,
    this.onKeepShoppingPressed,
  });

  void _defaultKeepShoppingPressed() {
    print('Keep Shopping button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814), // #603814
      body: SafeArea(
        child: Column(
          children: [
            // Header with buttons
            _buildHeader(context),

            // Main Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1), // #FFF8F1
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: _buildWishlistContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      child: Row(
        children: [
          const Spacer(),
          Row(
            children: [
              _buildIconButton(
                icon: Icons.favorite_border,
                onPressed: onFilterPressed,
              ),
              const SizedBox(width: 16),
              _buildIconButton(
                icon: Icons.settings_outlined,
                onPressed: onSettingsPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistContent(BuildContext context) {
    // Mock: treat "wishlist" as the subset of mock products marked favorite.
    // Later, replace with stored wishlist items from backend/local storage.
    final wishlistProducts = mockProducts.where((p) => p.isFavorite).toList();

    if (wishlistProducts.isEmpty) {
      return _buildEmptyStateContent();
    }

    return Column(
      children: [
        const SizedBox(height: 30),

        // Screen Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Wishlist',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: Color(0xFF241508),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.62,
            ),
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = wishlistProducts[index];
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
                  // TODO: Remove from wishlist later.
                },
              );
            },
          ),
        ),

      ],
    );
  }

  Widget _buildEmptyStateContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // Screen Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wishlist',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508), // #241508
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Empty state illustration area
            _buildEmptyStateIllustration(),
            
            const SizedBox(height: 70),
            
            // Empty state messages
            _buildEmptyStateMessages(),
            
            const SizedBox(height: 48),
            
            // CTA Button
            _buildKeepShoppingButton(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIllustration() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E0CE), // #F5E0CE
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Heart icon (using Flutter icon since no asset provided)
          Container(
            width: 105,
            height: 105,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 80,
              color: Color(0xFF603814), // Using theme color for icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateMessages() {
    return const Column(
      children: [
        // Main message
        Text(
          'Nothing saved yet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: Color(0xFF241508), // #241508
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 12),
        
        // Sub message
        Text(
          'Your saved items drop here',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: Color(0xFF1E2021), // #1E2021
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKeepShoppingButton() {
    return Center(
      child: SizedBox(
        width: 210,
        height: 57,
        child: ElevatedButton(
          onPressed: onKeepShoppingPressed ?? _defaultKeepShoppingPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFDAF40), // #FDAF40
            foregroundColor: const Color(0xFFFFFBF5), // #FFFBF5
            elevation: 8,
            shadowColor: const Color(0xFFFDAF40).withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 20,
            ),
          ),
          child: const Text(
            'Keep Shopping',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }
}