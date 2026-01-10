import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/home/presentation/screens/product_listing.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      categoryTitle: 'Brands',
      categoryDescription: 'Discover premium African brands.',
      sections: [
        CategorySection(
          title: 'Fashion',
          items: const ['View All', 'Luxury', 'Contemporary', 'Emerging'],
        ),
        CategorySection(
          title: 'Beauty',
          items: const ['View All', 'Skincare', 'Makeup', 'Fragrance'],
        ),
        CategorySection(
          title: 'Lifestyle',
          items: const ['View All', 'Home', 'Accessories', 'Wellness'],
        ),
      ],
      onItemTap: (section, item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Brands • ${section.title}',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      },
    );
  }
}