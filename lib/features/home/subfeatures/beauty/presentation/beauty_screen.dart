import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/home/subfeatures/beauty/presentation/business_profile_beauty.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

/// Afro Beauty screen with dropdown sections for Products and Services.
///
/// Backend category types:
/// - afro_beauty_products → Returns Products (2 levels, leaf only)
/// - afro_beauty_services → Returns BusinessProfiles (2 levels, leaf only)
class BeautyScreen extends ConsumerWidget {
  const BeautyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      categoriesByTypeProvider('afro_beauty_products'),
    );
    final servicesAsync = ref.watch(
      categoriesByTypeProvider('afro_beauty_services'),
    );

    // Combine both async states
    final isLoading = productsAsync.isLoading || servicesAsync.isLoading;
    final hasError = productsAsync.hasError && servicesAsync.hasError;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF603814),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF603814),
        body: SafeArea(
          child: Center(
            child: Text(
              'Failed to load categories',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final productCategories = productsAsync.value ?? [];
    final serviceCategories = servicesAsync.value ?? [];

    // Build sections: Products dropdown with subcategories, Services dropdown with subcategories
    final sections = <CategorySection>[];

    // Add Products section with its subcategories nested
    if (productCategories.isNotEmpty) {
      sections.add(
        CategorySection(
          title: 'Products',
          items: _buildCategoryItems(productCategories),
        ),
      );
    }

    // Add Services section with its subcategories nested
    if (serviceCategories.isNotEmpty) {
      sections.add(
        CategorySection(
          title: 'Services',
          items: _buildCategoryItems(serviceCategories),
        ),
      );
    }

    return CategoryScreen(
      categoryTitle: 'Afro Beauty',
      categoryDescription: 'Shop beauty products and find services',
      showBusinessTypeFilter: false,
      sections: sections,
      onItemTap: (section, item) {
        _handleItemTap(
          context,
          section,
          item,
          productCategories,
          serviceCategories,
        );
      },
    );
  }

  List<String> _buildCategoryItems(List<CategoryNode> categories) {
    final items = <String>[];
    for (final cat in categories) {
      items.add(cat.name);
      // Add children indented or as sub-items
      for (final child in cat.children) {
        items.add('  ${child.name}'); // Indent children
      }
    }
    return items;
  }

  void _handleItemTap(
    BuildContext context,
    CategorySection section,
    String item,
    List<CategoryNode> productCategories,
    List<CategoryNode> serviceCategories,
  ) {
    final isService = section.title == 'Services';
    final categories = isService ? serviceCategories : productCategories;
    final type = isService ? 'afro_beauty_services' : 'afro_beauty_products';

    // Remove indentation if present
    final cleanItem = item.trim();

    // Find the category node
    CategoryNode? targetNode;
    CategoryNode? parentNode;

    for (final cat in categories) {
      if (cat.name == cleanItem) {
        targetNode = cat;
        break;
      }
      for (final child in cat.children) {
        if (child.name == cleanItem) {
          targetNode = child;
          parentNode = cat;
          break;
        }
      }
      if (targetNode != null) break;
    }

    if (targetNode == null) return;

    final slug = targetNode.slug;
    final pageTitle = targetNode.name;
    final breadcrumb = parentNode != null
        ? 'Afro Beauty • ${section.title} • ${parentNode.name}'
        : 'Afro Beauty • ${section.title}';

    if (isService) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(
            type: type,
            slug: slug,
            pageTitle: pageTitle,
            breadcrumb: breadcrumb,
            showBusinessTypeFilter: true,
            onProductTap: (context, businessId) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      BusinessProfileBeautyScreen(businessId: businessId),
                ),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(
            type: type,
            slug: slug,
            pageTitle: pageTitle,
            breadcrumb: breadcrumb,
            showBusinessTypeFilter: false,
          ),
        ),
      );
    }
  }
}
