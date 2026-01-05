import 'package:flutter/material.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/product_filter_overlay.dart';

import '../../merchant_profile/presentation/merchant_profile_screen.dart';

import '../../home/presentation/home_screen.dart';
import '../../product_detail/presentation/product_detail_screen.dart';
import '../../home/presentation/widgets/product_listing.dart';
import '../../auth/presentation/reset_password.dart';
import '../../review_submission/presentation/review_submission.dart';
import '../../search/presentation/search_screen.dart';
import '../../shop_dashboard/presentation/shop_dashboard_screen.dart';

class ScreenGalleryScreen extends StatelessWidget {
  const ScreenGalleryScreen({super.key});

  static const routeName = '/_gallery';

  @override
  Widget build(BuildContext context) {
    final screens = <_GalleryEntry>[
      _GalleryEntry(
        title: 'Home',
        subtitle: 'HomeScreen',
        builder: (_) => const HomeScreen(),
      ),
      _GalleryEntry(
        title: 'Reset password',
        subtitle: 'ResetPasswordScreen',
        builder: (_) => const ResetPasswordScreen(),
      ),
      _GalleryEntry(
        title: 'Review submission',
        subtitle: 'ReviewSubmissionScreen',
        builder: (_) => const ReviewSubmissionScreen(),
      ),
      _GalleryEntry(
        title: 'Product filter',
        subtitle: 'ProductFilterOverlay',
        builder: (_) => const ProductFilterOverlay(),
      ),
      _GalleryEntry(
        title: 'Merchant profile',
        subtitle: 'MerchantProfileScreen',
        builder: (_) => const MerchantProfileScreen(),
      ),
      _GalleryEntry(
        title: 'Product listing',
        subtitle: 'ProductListingScreen',
        builder: (_) => const ProductListingScreen(
          pageTitle: 'Products',
          breadcrumb: 'Gallery',
        ),
      ),
      _GalleryEntry(
        title: 'Product detail',
        subtitle: 'ProductDetailPage',
        builder: (_) => const ProductDetailsScreen(),
      ),
      _GalleryEntry(
        title: 'Search',
        subtitle: 'SearchScreen',
        builder: (_) => const SearchScreen(),
      ),
      _GalleryEntry(
        title: 'Your shop dashboard',
        subtitle: 'YourShopDashboard',
        builder: (_) => const YourShopDashboard(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Gallery (temporary)')),
      body: ListView.separated(
        itemCount: screens.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = screens[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: entry.builder));
            },
          );
        },
      ),
    );
  }
}

class _GalleryEntry {
  const _GalleryEntry({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}
