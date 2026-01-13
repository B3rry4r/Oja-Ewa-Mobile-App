// beauty_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/home/subfeatures/beauty/presentation/business_profile_beauty.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

class BeautyScreen extends ConsumerWidget {
  const BeautyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider('beauty'));

    return categoriesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF603814),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF603814),
        body: SafeArea(
          child: Center(
            child: Text(
              'Failed to load categories',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      data: (cats) {
        final sections = cats
            .map(
              (c) => CategorySection(
                title: c.name,
                items: ['View All', ...c.children.map((ch) => ch.name)],
              ),
            )
            .toList();

        CategoryNode? findParentByTitle(String title) {
          for (final c in cats) {
            if (c.name == title) return c;
          }
          return null;
        }

        CategoryNode? findChildByName(CategoryNode parent, String childName) {
          for (final ch in parent.children) {
            if (ch.name == childName) return ch;
          }
          return null;
        }

        return CategoryScreen(
          categoryTitle: 'Beauty',
          categoryDescription: 'Find beauty businesses around',
          showBusinessTypeFilter: true,
          sections: sections,
          onItemTap: (section, item) {
            final parent = findParentByTitle(section.title);
            if (parent == null) return;

            final slug = item == 'View All' ? parent.slug : (findChildByName(parent, item)?.slug ?? parent.slug);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductListingScreen(
                  type: 'beauty',
                  slug: slug,
                  pageTitle: item == 'View All' ? section.title : item,
                  breadcrumb: 'Beauty • ${section.title}',
                  showBusinessTypeFilter: true,
                  onProductTap: (context) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BusinessProfileBeautyScreen()),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
