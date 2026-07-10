import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';

import 'add_edit_product.dart';

/// Screen to select product category type before adding a product.
///
/// Backend category types that return Products:
/// - textiles (3 levels) - requires: gender, style, tribe, size
/// - shoes_bags (3 levels) - requires: gender, style, tribe, size
/// - afro_beauty_products (2 levels) - does NOT require: gender, style, tribe, size
class SellerCategorySelectionScreen extends ConsumerStatefulWidget {
  const SellerCategorySelectionScreen({super.key});

  @override
  ConsumerState<SellerCategorySelectionScreen> createState() =>
      _SellerCategorySelectionScreenState();
}

class _SellerCategorySelectionScreenState
    extends ConsumerState<SellerCategorySelectionScreen> {
  String selectedCategoryType = "Textiles";

  // Product category types mapping
  // These types return Products (not BusinessProfiles)
  // Art has been moved here from Business profiles
  final List<Map<String, String>> categoryTypes = [
    {
      "name": "Textiles",
      "desc": "Dresses, Suits, Tops, Traditional Wear",
      "type": "textiles",
    },
    {
      "name": "Shoes & Bags",
      "desc": "Footwear, Handbags, Accessories",
      "type": "shoes_bags",
    },
    {
      "name": "Beauty Products",
      "desc": "Hair Care, Skin Care, Makeup",
      "type": "afro_beauty_products",
    },
    {
      "name": "Art",
      "desc": "Sculpture, Painting, Mixed Media, Installation",
      "type": "art",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      // Body is a ListView/GridView: it needs a bounded height and scrolls itself.
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Screen Title
          Text(
            "What are you selling?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select the category for your product",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Category Type Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 168 / 160,
              ),
              itemCount: categoryTypes.length,
              itemBuilder: (context, index) {
                final cat = categoryTypes[index];
                return _buildCategoryCard(
                  cat["name"]!,
                  cat["desc"]!,
                  isSelected: selectedCategoryType == cat["name"],
                );
              },
            ),
          ),

          // Continue Button
          _buildContinueButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String name,
    String desc, {
    bool isSelected = false,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => setState(() => selectedCategoryType = name),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? colors.textPrimary : colors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isSelected ? colors.background : colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? colors.background.withValues(alpha: 0.8)
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getApiType(String displayName) {
    final cat = categoryTypes.firstWhere(
      (c) => c['name'] == displayName,
      orElse: () => {'type': 'textiles'},
    );
    return cat['type'] ?? 'textiles';
  }

  Widget _buildContinueButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () async {
        final apiType = _getApiType(selectedCategoryType);

        // Fetch categories for selected type
        final catalog = await ref.read(allCategoriesProvider.future);
        if (!mounted) return;

        final roots = catalog.categories[apiType] ?? const [];
        if (roots.isEmpty) {
          AppSnackbars.showError(
            context,
            'No categories available for $selectedCategoryType',
          );
          return;
        }

        // Show category tree picker to select specific category
        final selectedNode = await showCategoryTreePickerSheet(
          context: context,
          title: 'Select $selectedCategoryType Category',
          roots: roots,
        );
        if (selectedNode == null) return;

        if (!context.mounted) return;

        // Navigate to Add Product screen with category info
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddProductScreen(
              categoryType: apiType,
              categoryId: selectedNode.id,
              categoryName: selectedNode.name,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Continue",
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
