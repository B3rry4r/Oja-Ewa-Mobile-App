import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/widgets/category_screen.dart';
import 'package:ojaewa/features/home/presentation/widgets/product_listing.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      categoryTitle: 'Market',
      categoryDescription: 'Shop premium african styles.',
      sections: [
        CategorySection(
          title: 'Men',
          items: const ['View All', 'Agbada', 'Danshiki', 'Native Wears'],
        ),
        CategorySection(
          title: 'Women',
          items: const ['View All', 'Dress', 'Skirt and Blouse', 'Boubou'],
        ),
      ],
      onItemTap: (section, item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Market • ${section.title}',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      },
    );
  }
}