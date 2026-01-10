// schools_screen.dart
import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

class SchoolsScreen extends StatelessWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      categoryTitle: 'Schools',
      categoryDescription: 'Find certified schools to learn from',
      sections: [
        CategorySection(
          title: 'Fashion',
          items: const [
            'View All',
            'Fashion Design',
            'Textile Design',
            'Pattern Making',
            'Fashion Merchandising',
            'Fashion Styling',
            'Costume Design',
            'Fashion Marketing',
          ],
        ),
        CategorySection(
          title: 'Catering',
          items: const [
            'View All',
            'Culinary Arts',
            'Baking & Pastry',
            'Food Safety',
            'Menu Planning',
            'Catering Management',
            'International Cuisine',
            'Nutrition',
          ],
        ),
        CategorySection(
          title: 'Music',
          items: const [
            'View All',
            'Music Theory',
            'Instrument Training',
            'Vocal Training',
            'Music Production',
            'Sound Engineering',
            'Music Business',
            'Songwriting',
          ],
        ),
      ],
      onItemTap: (section, item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Schools • ${section.title}',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      },
    );
  }
}