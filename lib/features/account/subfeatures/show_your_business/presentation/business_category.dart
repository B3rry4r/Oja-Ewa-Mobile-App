import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/selected_category_forms/business_registration_draft.dart';

import '../../../../../app/router/app_router.dart';

class BusinessCategoryScreen extends ConsumerStatefulWidget {
  const BusinessCategoryScreen({super.key});

  @override
  ConsumerState<BusinessCategoryScreen> createState() =>
      _BusinessCategoryScreenState();
}

class _BusinessCategoryScreenState
    extends ConsumerState<BusinessCategoryScreen> {
  // Local state to track selection
  String selectedCategory = "Schools";

  // Data mapping based on backend category types
  // Currently only Schools is enabled for business registration
  final List<Map<String, String>> categories = [
    {
      "name": "Schools",
      "desc": "Fashion, Beauty, Catering, Music",
      "type": "school",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Screen Title
          Text(
            "Choose a business category",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 24),

          // Responsive Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 168 / 160, // Aspect ratio from IR sizes
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _buildCategoryCard(
                  cat["name"]!,
                  cat["desc"]!,
                  isSelected: selectedCategory == cat["name"],
                );
              },
            ),
          ),

          // Primary Action Button
          _buildSaveButton(context),
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
      onTap: () => setState(() => selectedCategory = name),
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
                fontFamily: 'Campton',
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
                fontFamily: 'Campton',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryNode> _rootsForLabel(
    Map<String, List<CategoryNode>> all,
    String label,
  ) {
    // Map UI labels to backend category types
    // Currently only Schools is enabled
    switch (label) {
      case 'Schools':
        return all['school'] ?? const [];
      default:
        return all[label.toLowerCase()] ?? const [];
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () async {
        final catalog = await ref.read(allCategoriesProvider.future);
        if (!mounted) return;

        final roots = _rootsForLabel(catalog.categories, selectedCategory);
        if (roots.isEmpty) {
          AppSnackbars.showError(context, 'No categories available');
          return;
        }

        final selectedNode = await showCategoryTreePickerSheet(
          context: context,
          title: 'Select Category',
          roots: roots,
        );
        if (selectedNode == null) return;

        final draft = BusinessRegistrationDraft(categoryLabel: selectedCategory)
          ..categoryId = selectedNode.parentId ?? selectedNode.id
          ..subcategoryId = selectedNode.id;

        if (!context.mounted) return;
        Navigator.of(context).pushNamed(
          AppRoutes.businessSellerRegistration,
          arguments: draft.toJson(),
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
            "Save and Continue",
            style: TextStyle(
              color: colors.onAccent,
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
