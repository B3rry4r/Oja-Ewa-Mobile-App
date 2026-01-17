import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/core/resources/app_assets.dart';

class ProductFilterOverlay extends StatelessWidget {
  const ProductFilterOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E2021).withValues(alpha: 0.8),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(11),
              bottomRight: Radius.circular(11),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              _buildCategoryFilterSection(),
              _buildReviewsFilterSection(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Top header with filter bar
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter By',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF301C0A),
            ),
          ),
          const SizedBox(height: 16),

          // Active filter tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.filter,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF241508),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'men',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF241508),
                  ),
                ),
                const SizedBox(width: 16),
                // No forward-arrow SVG asset exists; reuse back.svg rotated.
                Transform.rotate(
                  angle: 3.141592653589793, // pi
                  child: SvgPicture.asset(
                    AppIcons.back,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF241508),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Category filter section
  Widget _buildCategoryFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF301C0A),
            ),
          ),

          const SizedBox(height: 12),

          // First row of category tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryTag('Market', isActive: true),
              _buildCategoryTag('Beauty', isActive: false),
              _buildCategoryTag('Brands', isActive: false),
              _buildCategoryTag('Music', isActive: false),
            ],
          ),

          const SizedBox(height: 8),

          // Second row of category tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryTag('Schools', isActive: false),
              _buildCategoryTag('Sustainability', isActive: false),
            ],
          ),

          const SizedBox(height: 24),

          // Price range heading
          const Text(
            'Price Range',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF301C0A),
            ),
          ),

          const SizedBox(height: 8),

          // Price range slider
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    height: 7,
                    width: 341,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA15E22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category tag widget
  Widget _buildCategoryTag(String text, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFA15E22) : Colors.transparent,
        border: isActive ? null : Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: isActive ? const Color(0xFFFBFBFB) : const Color(0xFF301C0A),
        ),
      ),
    );
  }

  // Reviews filter section
  Widget _buildReviewsFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Reviews',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF301C0A),
            ),
          ),

          const SizedBox(height: 12),

          // Rating filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRatingFilterChip('5-4'),
              _buildRatingFilterChip('4-3'),
              _buildRatingFilterChip('3-1'),
            ],
          ),
        ],
      ),
    );
  }

  // Rating filter chip widget
  Widget _buildRatingFilterChip(String ratingRange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Color(0xFFFFDB80)),
          const SizedBox(width: 4),
          Text(
            ratingRange,
            style: const TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF301C0A),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom action buttons
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: const BorderSide(color: Color(0xFFFDAF40)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFFFDAF40),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: const Color(0xFFFDAF40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
