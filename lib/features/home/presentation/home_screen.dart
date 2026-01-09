import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(color: const Color(0xFFFFF8F1)),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),

                    // Header
                    _buildHeader(context),

                    const SizedBox(height: 24),

                    // Promo Cards (Horizontal Scroll)
                    _buildPromoCardsSection(),

                    const SizedBox(height: 32),

                    // Hero Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _buildHeroTitle(),
                    ),

                    const SizedBox(height: 24),

                    // Category Grid Section with light background
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF8F1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 16,
                        right: 16,
                        bottom: 32,
                      ),
                      child: _buildCategoryGrid(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Row(
            children: [
              // Logo Mark (stacked lines)
              SvgPicture.asset('app_icon/app_logo_2.svg',
              width: 24,
              ),
              const SizedBox(width: 8),
              // Brand Name
              const Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'oj',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 1),
                  Text(
                    'à-ewà',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '®',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Header Icons
          Row(
            children: [
              // Bag Icon
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.yourShopDashboard),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Notification Icon
              InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Cart Icon
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCardsSection() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          // Promo Card 1 - 40% Off
          Container(
            width: 254,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Decorative Circles
                Positioned(
                  right: 20,
                  top: 10,
                  child: Container(
                    width: 77,
                    height: 77,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 73,
                  child: Container(
                    width: 77,
                    height: 77,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                ),
                // Promo Text
                const Positioned(
                  left: 24,
                  top: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '40%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                      Text(
                        'off',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Promo Card 2
          Container(
            width: 257,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFA15E22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Special Offer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTitle() {
    return const Text(
      'Where would\nyou like to go?',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFF241508),
        height: 1.2,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 168 / 186,
      children: [
        // Market
        _buildCategoryItem(
          context: context,
          title: 'Market',
          color: const Color(0xFFDD995C),
          icon: Icons.storefront_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.market),
        ),
        // Beauty
        _buildCategoryItem(
          context: context,
          title: 'Beauty',
          color: const Color(0xFFA15E22),
          icon: Icons.face_retouching_natural_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.beauty),
        ),
        // Brands
        _buildCategoryItem(
          context: context,
          title: 'Brands',
          color: const Color(0xFFA15E22),
          icon: Icons.branding_watermark_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.brands),
        ),
        // Music
        _buildCategoryItem(
          context: context,
          title: 'Music',
          color: const Color(0xFFEBC29D),
          icon: Icons.music_note_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.music),
        ),
        // Schools
        _buildCategoryItem(
          context: context,
          title: 'Schools',
          color: const Color(0xFFFECF8C),
          icon: Icons.school_outlined,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.schools),
        ),
        // Sustainability
        _buildCategoryItem(
          context: context,
          title: 'Sustainability',
          color: const Color(0xFFA15E22),
          icon: Icons.eco_outlined,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.sustainability),
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
