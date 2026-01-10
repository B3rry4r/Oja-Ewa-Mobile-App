// sustainability_screen.dart
import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

class SustainabilityScreen extends StatelessWidget {
  const SustainabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScreen(
      categoryTitle: 'Sustainability',
      categoryDescription: 'Events, Growth, Productivity',
      sections: [
        CategorySection(
          title: 'Trainings and Development',
          items: const [
            'View All',
            'Professional Skills',
            'Leadership Training',
            'Technical Workshops',
            'Certification Programs',
            'Career Development',
            'Online Courses',
            'Mentorship Programs',
          ],
        ),
        CategorySection(
          title: 'Empowerment',
          items: const [
            'View All',
            'Women Empowerment',
            'Youth Programs',
            'Community Initiatives',
            'Financial Literacy',
            'Entrepreneurship',
            'Skills Development',
            'Social Impact',
          ],
        ),
        CategorySection(
          title: 'Events',
          items: const [
            'View All',
            'Workshops',
            'Seminars',
            'Conferences',
            'Networking Events',
            'Webinars',
            'Community Gatherings',
            'Awareness Campaigns',
          ],
        ),
        CategorySection(
          title: 'Partnership & Collaboration',
          items: const [
            'View All',
            'Corporate Partnerships',
            'NGO Collaborations',
            'Government Programs',
            'Academic Partnerships',
            'Community Alliances',
            'International Cooperation',
          ],
        ),
        CategorySection(
          title: 'Explore More',
          items: const [
            'Environmental Sustainability',
            'Social Responsibility',
            'Economic Development',
            'Innovation Projects',
            'Research & Development',
            'Sustainability Awards',
          ],
          hasTrailingIcon: false,
          hasBorder: false,
        ),
      ],
      onItemTap: (section, item) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              pageTitle: item == 'View All' ? section.title : item,
              breadcrumb: 'Sustainability • ${section.title}',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      },
    );
  }
}