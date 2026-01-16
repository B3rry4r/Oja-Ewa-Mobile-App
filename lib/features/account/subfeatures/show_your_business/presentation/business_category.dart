import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/selected_category_forms/business_registration_draft.dart';

import '../../../../../app/router/app_router.dart';

class BusinessCategoryScreen extends ConsumerStatefulWidget {
  const BusinessCategoryScreen({super.key});

  @override
  ConsumerState<BusinessCategoryScreen> createState() => _BusinessCategoryScreenState();
}

class _BusinessCategoryScreenState extends ConsumerState<BusinessCategoryScreen> {
  // Local state to track selection
  String selectedCategory = "Beauty";

  // Data mapping based on backend category types
  // Business profiles now only use: afro_beauty_services, school
  // Art has been moved to Products (not BusinessProfiles)
  final List<Map<String, String>> categories = [
    {
      "name": "Beauty",
      "desc": "Hair Care, Skin Care, Makeup Services, Spa, Salons",
      "type": "afro_beauty_services",
    },
    {
      "name": "Schools",
      "desc": "Fashion, Beauty, Catering, Music",
      "type": "school",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
              ),
              const SizedBox(height: 32),
              
              // Screen Title
              const Text(
                "Choose a business category",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F1011),
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
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, String desc, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = name),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF603814) : const Color(0xFFFFF8F1),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF1E2021),
                fontFamily: 'Campton',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF777F84),
                fontFamily: 'Campton',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryNode> _rootsForLabel(Map<String, List<CategoryNode>> all, String label) {
    // Map UI labels to backend category types
    // Business profiles now only use: afro_beauty_services, school
    // Art has been moved to Products
    switch (label) {
      case 'Beauty':
        return all['afro_beauty_services'] ?? const [];
      case 'Schools':
        return all['school'] ?? const [];
      default:
        return all[label.toLowerCase()] ?? const [];
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final all = await ref.read(allCategoriesProvider.future);
        if (!mounted) return;

        final roots = _rootsForLabel(all, selectedCategory);
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
        color: const Color(0xFFFDAF40), // Orange from IR
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: const Center(
        child: Text(
          "Save and Continue",
          style: TextStyle(
            color: Color(0xFFFFFBF5),
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