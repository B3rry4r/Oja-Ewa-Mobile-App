import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/adverts/domain/advert.dart';
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

                      // Promo banner - full-width fade carousel via /api/adverts
                      _buildAdvertsOrFallback(context, ref),

                      const SizedBox(height: 24),

                      // For You - AI Personalized Section
                      // _buildForYouSection(context, ref),
                      const SizedBox(height: 12),

                      // Hero Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildHeroTitle(),
                      ),

                      const SizedBox(height: 12),

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
                          top: 12,
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
          // Brand Logo with text (PNG for correct colors)
          Image.asset(
            'assets/app_icon/logo2.png',
            width: 120, // Wider to accommodate logo + text
            height: 28,
            fit: BoxFit.contain,
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

  Widget _buildAdvertsOrFallback(BuildContext context, WidgetRef ref) {
    final advertsAsync = ref.watch(advertsByPositionProvider('banner'));

    return advertsAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => _buildPromoCardsSection(),
      data: (adverts) {
        if (adverts.isEmpty) return _buildPromoCardsSection();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _AdvertFadeCarousel(
            adverts: adverts,
            onTap: (ad) => _handleAdvertTap(context, ad),
          ),
        );
      },
    );
  }

  Future<void> _handleAdvertTap(BuildContext context, Advert ad) async {
    final actionUrl = ad.actionUrl;
    if (actionUrl == null || actionUrl.isEmpty) return;

    if (actionUrl.startsWith('/')) {
      if (actionUrl.contains('textiles')) {
        Navigator.of(context).pushNamed(AppRoutes.market);
      } else if (actionUrl.contains('beauty')) {
        Navigator.of(context).pushNamed(AppRoutes.beauty);
      } else if (actionUrl.contains('shoes') || actionUrl.contains('bags')) {
        Navigator.of(context).pushNamed(AppRoutes.brands);
      } else if (actionUrl.contains('art')) {
        Navigator.of(context).pushNamed(AppRoutes.music);
      } else if (actionUrl.contains('school')) {
        Navigator.of(context).pushNamed(AppRoutes.schools);
      } else if (actionUrl.contains('hardware') ||
          actionUrl.contains('sustain')) {
        Navigator.of(context).pushNamed(AppRoutes.hardware);
      } else {
        Navigator.of(context).pushNamed(AppRoutes.home);
      }
      return;
    }

    final uri = Uri.tryParse(actionUrl);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPromoCardsSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: _AdvertFadeCarousel.aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFFDAF40),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Discover curated drops',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF241508),
                    fontFamily: 'Campton',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Fashion, beauty, art, education, and hardware in one marketplace.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Color(0xFF241508),
                    fontFamily: 'Campton',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTitle() {
    return const Text(
      'Find What Speaks\nTo Your Soul',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF603814),
        height: 1.2,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
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
          title: 'Footwear/Bags',
          color: const Color(0xFFA15E22),
          iconAsset: AppIcons.brands,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.brands),
        ),
        // Music
        _buildCategoryItem(
          context: context,
          title: 'Art Market',
          color: const Color(0xFFEBC29D),
          iconAsset: AppIcons.music,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.music),
        ),
        // Schools
        _buildCategoryItem(
          context: context,
          title: 'Education',
          color: const Color(0xFFFECF8C),
          iconAsset: AppIcons.schools,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.schools),
        ),
        // Hardware
        _buildCategoryItem(
          context: context,
          title: 'Hardware',
          color: const Color(0xFFA15E22),
          iconAsset: AppIcons.hardware,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.hardware),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(iconAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
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
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.personalizedRecommendations),
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
}

class _AdvertFadeCarousel extends StatefulWidget {
  const _AdvertFadeCarousel({required this.adverts, required this.onTap});

  static const double aspectRatio = 16 / 9;

  final List<Advert> adverts;
  final Future<void> Function(Advert advert) onTap;

  @override
  State<_AdvertFadeCarousel> createState() => _AdvertFadeCarouselState();
}

class _AdvertFadeCarouselState extends State<_AdvertFadeCarousel> {
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _AdvertFadeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adverts.length != widget.adverts.length) {
      _currentIndex = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.adverts.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.adverts.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAdvert = widget.adverts[_currentIndex];

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _AdvertFadeCarousel.aspectRatio,
          child: GestureDetector(
            onTap: () => widget.onTap(currentAdvert),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _AdvertBannerCard(
                key: ValueKey(currentAdvert.id),
                advert: currentAdvert,
              ),
            ),
          ),
        ),
        if (widget.adverts.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.adverts.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF603814)
                      : const Color(0xFFD7C6B6),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _AdvertBannerCard extends StatelessWidget {
  const _AdvertBannerCard({super.key, required this.advert});

  final Advert advert;

  @override
  Widget build(BuildContext context) {
    final title = advert.title.trim();
    final description = (advert.description ?? '').trim();
    final imageUrl = (advert.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFDAF40),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: hasImage
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xD9241508),
                        Color(0x99241508),
                        Color(0x33241508),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFDAF40), Color(0xFFDD995C)],
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: hasImage ? Colors.white : const Color(0xFF241508),
                    fontFamily: 'Campton',
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: hasImage
                            ? Colors.white.withValues(alpha: 0.92)
                            : const Color(0xFF241508),
                        fontFamily: 'Campton',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
