import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/adverts/presentation/controllers/adverts_controller.dart';

import '../../../app/router/app_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      floatingActionButton: _buildAiChatFab(context),
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFFFF8F1)),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),

                      // Header
                      _buildHeader(context),

                      const SizedBox(height: 24),

                      // Promo Cards (Horizontal Scroll) - now API driven via /api/adverts
                      _buildAdvertsOrFallback(ref),

                      const SizedBox(height: 24),

                      // For You - AI Personalized Section
                      _buildForYouSection(context, ref),

                      const SizedBox(height: 24),

                      // Hero Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildHeroTitle(),
                      ),

                      const SizedBox(height: 20),

                      // Category Grid Section with light background
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF8F1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        padding: const EdgeInsets.only(
                          top: 24,
                          left: 16,
                          right: 16,
                          bottom: 32,
                        ),
                        child: _buildCategoryGrid(context),
                      ),
                      const SizedBox(height: AppBottomNavBar.height),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          Row(
            children: [
              // Logo Mark
              SvgPicture.asset(AppImages.appLogoAlt, width: 24, height: 24),
              const SizedBox(width: 8),
              // Brand Name
              const Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'oj',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 1),
                  Text(
                    'à-ewà',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '®',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Header Icons
          Row(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  // Watch the async provider directly to ensure rebuild on data arrival
                  final sellerStatusAsync = ref.watch(mySellerStatusProvider);

                  return sellerStatusAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (status) {
                      final isApproved = status?.isApprovedAndActive ?? false;
                      if (!isApproved) {
                        return const SizedBox.shrink();
                      }
                      return HeaderIconButton(
                        asset: AppIcons.shop,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.yourShopDashboard),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              // Notification icon with badge
              Consumer(
                builder: (context, ref, _) {
                  final accessToken = ref.watch(accessTokenProvider);
                  final isAuthenticated =
                      accessToken != null && accessToken.isNotEmpty;
                  final unreadCount = isAuthenticated
                      ? ref
                            .watch(unreadCountProvider)
                            .maybeWhen(data: (count) => count, orElse: () => 0)
                      : 0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      HeaderIconButton(
                        asset: AppIcons.notification,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.notifications),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDAF40),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Campton',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
              HeaderIconButton(
                asset: AppIcons.bag,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertsOrFallback(WidgetRef ref) {
    final advertsAsync = ref.watch(advertsByPositionProvider('banner'));

    return advertsAsync.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => _buildPromoCardsSection(),
      data: (adverts) {
        if (adverts.isEmpty) return _buildPromoCardsSection();

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: adverts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final ad = adverts[index];
              return GestureDetector(
                onTap: () async {
                  final actionUrl = ad.actionUrl;
                  if (actionUrl != null && actionUrl.isNotEmpty) {
                    // Handle relative URLs as in-app navigation
                    if (actionUrl.startsWith('/')) {
                      // Relative URL - navigate within the app
                      // Map known paths to app routes
                      if (actionUrl.contains('textiles')) {
                        Navigator.of(context).pushNamed(AppRoutes.market);
                      } else if (actionUrl.contains('beauty')) {
                        Navigator.of(context).pushNamed(AppRoutes.beauty);
                      } else if (actionUrl.contains('shoes') ||
                          actionUrl.contains('bags')) {
                        Navigator.of(context).pushNamed(AppRoutes.brands);
                      } else if (actionUrl.contains('art')) {
                        Navigator.of(context).pushNamed(AppRoutes.music);
                      } else if (actionUrl.contains('school')) {
                        Navigator.of(context).pushNamed(AppRoutes.schools);
                      } else if (actionUrl.contains('sustain')) {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.sustainability);
                      } else {
                        // Default to home for unknown relative paths
                        Navigator.of(context).pushNamed(AppRoutes.home);
                      }
                    } else {
                      // Absolute URL - open externally
                      final uri = Uri.tryParse(actionUrl);
                      if (uri != null &&
                          (uri.scheme == 'http' || uri.scheme == 'https')) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  }
                },
                child: Container(
                  width: 254,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFFDAF40),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ad.imageUrl == null
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ad.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              if ((ad.description ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  ad.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ],
                          ),
                        )
                      : Image.network(ad.imageUrl!, fit: BoxFit.cover),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPromoCardsSection() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          // Promo Card 1 - 40% Off
          Container(
            width: 254,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Decorative Circles
                Positioned(
                  right: 20,
                  top: 10,
                  child: Container(
                    width: 77,
                    height: 77,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 73,
                  child: Container(
                    width: 77,
                    height: 77,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                ),
                // Promo Text
                const Positioned(
                  left: 24,
                  top: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '40%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                      Text(
                        'off',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Promo Card 2
          Container(
            width: 257,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFA15E22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Special Offer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTitle() {
    return const Text(
      'Find What Speaks\nTo Your Soul',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFF241508),
        height: 1.2,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 168 / 186,
      children: [
        // Market
        _buildCategoryItem(
          context: context,
          title: 'Textiles',
          color: const Color(0xFFDD995C),
          iconAsset: AppIcons.market,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.market),
        ),
        // Beauty
        _buildCategoryItem(
          context: context,
          title: 'Afro Beauty',
          color: const Color(0xFFA15E22),
          iconAsset: AppIcons.beauty,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.beauty),
        ),
        // Brands
        _buildCategoryItem(
          context: context,
          title: 'Shoes & Bags',
          color: const Color(0xFFA15E22),
          iconAsset: AppIcons.brands,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.brands),
        ),
        // Music
        _buildCategoryItem(
          context: context,
          title: 'Art',
          color: const Color(0xFFEBC29D),
          iconAsset: AppIcons.music,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.music),
        ),
        // Schools
        _buildCategoryItem(
          context: context,
          title: 'Schools',
          color: const Color(0xFFFECF8C),
          iconAsset: AppIcons.schools,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.schools),
        ),
        // Sustainability
        _buildCategoryItem(
          context: context,
          title: 'Sustainability',
          color: const Color(0xFFA15E22),
          iconAsset: AppIcons.sustainability,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.sustainability),
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String title,
    required Color color,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(iconAsset, fit: BoxFit.cover),
      ),
    );
  }

  /// For You - AI Personalized recommendations section
  Widget _buildForYouSection(BuildContext context, WidgetRef ref) {
    final token = ref.watch(accessTokenProvider);
    final isLoggedIn = token != null && token.isNotEmpty;

    // Only show for logged-in users
    if (!isLoggedIn) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.personalizedRecommendations),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDAF40), Color(0xFFFFCC80)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFDAF40).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-curated picks based on your style',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Campton',
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Floating Action Button for AI Cultural Assistant
  Widget _buildAiChatFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.aiChat),
      backgroundColor: const Color(0xFFFDAF40),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.psychology, size: 24),
      label: const Text(
        'Ask AI',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 4,
    );
  }
}
