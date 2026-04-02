import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

class MusicScreen extends ConsumerWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider('art'));

    return categoriesAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.appColors.background,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: context.appColors.background,
        body: SafeArea(
          child: Center(
            child: Text(
              'Failed to load categories',
              style: TextStyle(color: context.appColors.textPrimary),
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
          categoryTitle: 'Art Market',
          categoryDescription: 'Explore African art and creative works.',
          sections: sections,
          onItemTap: (section, item) {
            final parent = findParentByTitle(section.title);
            if (parent == null) return;

            final slug = item == 'View All'
                ? parent.slug
                : (findChildByName(parent, item)?.slug ?? parent.slug);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductListingScreen(
                  type: 'art',
                  slug: slug,
                  pageTitle: item == 'View All' ? section.title : item,
                  breadcrumb: 'Art Market • ${section.title}',
                  showBusinessTypeFilter: false,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
