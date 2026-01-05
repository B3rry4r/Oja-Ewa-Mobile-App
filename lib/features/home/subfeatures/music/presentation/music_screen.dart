import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/widgets/category_screen.dart';
import 'package:ojaewa/features/home/presentation/widgets/product_listing.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      categoryTitle: 'Music',
      categoryDescription: 'African music and entertainment.',
      sections: [
        CategorySection(
          title: 'Genres',
          items: const ['View All', 'Afrobeats', 'Highlife', 'Gospel'],
        ),
        CategorySection(
          title: 'Artists',
          items: const ['View All', 'Popular', 'New Artists', 'Legends'],
        ),
      ],
      onItemTap: (section, item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Music • ${section.title}',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      },
    );
  }
}