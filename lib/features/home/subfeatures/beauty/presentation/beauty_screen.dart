// beauty_screen.dart
import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';
import 'package:ojaewa/features/home/subfeatures/beauty/presentation/business_profile_beauty.dart';

class BeautyScreen extends StatelessWidget {
  const BeautyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      categoryTitle: 'Beauty',
      categoryDescription: 'Find beauty businesses around',
      showBusinessTypeFilter: true,
      sections: [
        CategorySection(
          title: 'Products',
          items: const [
            'View All',
            'Skincare',
            'Make Up',
            'Bath and Body',
            'Hair Care',
            'Fragrances',
            'Nail Care',
            'Tools & Accessories',
          ],
        ),
        CategorySection(
          title: 'Services',
          items: const [
            'View All',
            'Salon Services',
            'Spa Treatments',
            'Makeup Artists',
            'Hair Stylists',
            'Nail Technicians',
            'Skincare Specialists',
            'Bridal Services',
          ],
        ),
        CategorySection(
          title: 'Brands',
          items: const [
            'View All',
            'Luxury Brands',
            'Natural & Organic',
            'African Brands',
            'International Brands',
            'Emerging Brands',
          ],
        ),
        CategorySection(
          title: 'Professionals',
          items: const [
            'View All',
            'Makeup Artists',
            'Hair Stylists',
            'Estheticians',
            'Nail Technicians',
            'Brow Specialists',
            'Lash Technicians',
          ],
        ),
      ],
      onItemTap: (section, item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Beauty • ${section.title}',
              showBusinessTypeFilter: true,
              onProductTap: (context) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BusinessProfileBeautyScreen(),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
