import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

/// Afro Beauty screen - displays products only
///
/// Backend category type:
/// - afro_beauty_products → Returns Products (3 levels: Kids/Women/Men → subcategories → leaf)
/// Note: afro_beauty_services was removed from backend
class BeautyScreen extends ConsumerWidget {
  const BeautyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use categoriesByTypeProvider - backend now returns full nested tree
    final productsAsync = ref.watch(categoriesByTypeProvider('afro_beauty_products'));

    // Check async state
    final isLoading = productsAsync.isLoading;
    final hasError = productsAsync.hasError;

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

    // Build sections from product categories (Kids/Women/Men)
    final sections = productCategories
        .map(
          (cat) => CategorySection(
            title: cat.name,
            items: ['View All', ...cat.children.map((ch) => ch.name)],
          ),
        )
        .toList();

    return CategoryScreen(
      categoryTitle: 'Afro Beauty',
      categoryDescription: 'Shop beauty products',
      showBusinessTypeFilter: false,
      sections: sections,
      onItemTap: (section, item) {
        final parent = productCategories.firstWhere(
          (c) => c.name == section.title,
          orElse: () => productCategories.first,
        );

        final slug = item == 'View All'
            ? parent.slug
            : (parent.children.firstWhere((ch) => ch.name == item, orElse: () => parent).slug);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              type: 'afro_beauty_products',
              slug: slug,
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Afro Beauty • ${section.title}',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      },
    );
  }
}
