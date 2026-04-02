import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

class ProductFilterOverlay extends StatelessWidget {
  const ProductFilterOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
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
              _buildHeaderSection(context),
              _buildCategoryFilterSection(context),
              _buildReviewsFilterSection(context),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Top header with filter bar
  Widget _buildHeaderSection(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter By',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Active filter tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppIcons.filter,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'men',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: colors.textPrimary,
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
                    colorFilter: ColorFilter.mode(
                      colors.textPrimary,
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
  Widget _buildCategoryFilterSection(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // First row of category tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryTag(context, 'Market', isActive: true),
              _buildCategoryTag(context, 'Beauty', isActive: false),
              _buildCategoryTag(context, 'Brands', isActive: false),
              _buildCategoryTag(context, 'Music', isActive: false),
            ],
          ),

          const SizedBox(height: 8),

          // Second row of category tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryTag(context, 'Schools', isActive: false),
              _buildCategoryTag(context, 'Hardware', isActive: false),
            ],
          ),

          const SizedBox(height: 24),

          // Price range heading
          Text(
            'Price Range',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Price range slider
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: colors.border,
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
                      color: colors.accent,
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
  Widget _buildCategoryTag(
    BuildContext context,
    String text, {
    required bool isActive,
  }) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? colors.accent : Colors.transparent,
        border: isActive ? null : Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: isActive ? colors.onAccent : colors.textPrimary,
        ),
      ),
    );
  }

  // Reviews filter section
  Widget _buildReviewsFilterSection(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Reviews',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Rating filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRatingFilterChip(context, '5-4'),
              _buildRatingFilterChip(context, '4-3'),
              _buildRatingFilterChip(context, '3-1'),
            ],
          ),
        ],
      ),
    );
  }

  // Rating filter chip widget
  Widget _buildRatingFilterChip(BuildContext context, String ratingRange) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: colors.accent),
          const SizedBox(width: 4),
          Text(
            ratingRange,
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom action buttons
  Widget _buildActionButtons(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: BorderSide(color: colors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colors.accent,
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
                backgroundColor: colors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Apply',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colors.onAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
