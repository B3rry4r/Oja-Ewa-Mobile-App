import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
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
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? colors.surface : colors.surfaceSecondary,
              colors.background,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdvertsOrFallback(context, ref),
                      const SizedBox(height: 24),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildHeroTitle(context),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
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
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo with text (PNG for correct colors)
          Theme.of(context).brightness == Brightness.dark
              ? SvgPicture.asset(
                  AppIcons.brandMarkWhite,
                  width: 98,
                  height: 22,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  'assets/app_icon/logo2.png',
                  width: 98,
                  height: 22,
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
                    error: (error, stackTrace) => const SizedBox.shrink(),
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
                            decoration: BoxDecoration(
                              color: colors.accent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Color(0xFF111111),
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
      error: (error, stackTrace) => _buildPromoCardsSection(context),
      data: (adverts) {
        if (adverts.isEmpty) return _buildPromoCardsSection(context);

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

  Widget _buildPromoCardsSection(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: _AdvertFadeCarousel.aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Discover curated drops',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontFamily: 'Campton',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fashion, beauty, art, education, and hardware in one marketplace.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: colors.textPrimary,
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

  Widget _buildHeroTitle(BuildContext context) {
    final colors = context.appColors;
    return Text(
      'Based on who you be',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
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
      childAspectRatio: 1.02,
      children: [
        // Market
        _buildCategoryItem(
          context: context,
          title: 'Textiles',
          description: 'Fabrics, prints & timeless styles',
          color: const Color(0xFFC7853D),
          iconAsset: AppIcons.market,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.market),
        ),
        // Beauty
        _buildCategoryItem(
          context: context,
          title: 'Afro Beauty',
          description: 'Skincare, makeup, cosmetics & hairs.',
          color: const Color(0xFFAB6730),
          iconAsset: AppIcons.beauty,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.beauty),
        ),
        // Brands
        _buildCategoryItem(
          context: context,
          title: 'Footwear/Bags',
          description: 'Step out in style',
          color: const Color(0xFF9F5A35),
          iconAsset: AppIcons.brands,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.brands),
        ),
        // Music
        _buildCategoryItem(
          context: context,
          title: 'Art Market',
          description: 'Art for every vision',
          color: const Color(0xFFCC8E5B),
          iconAsset: AppIcons.music,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.music),
        ),
        // Schools
        _buildCategoryItem(
          context: context,
          title: 'Education',
          description: 'Learn, grow & build your future',
          color: const Color(0xFFD39A54),
          iconAsset: AppIcons.schools,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.schools),
        ),
        // Hardware
        _buildCategoryItem(
          context: context,
          title: 'Hardware',
          description: 'Tools for builders and innovators',
          color: const Color(0xFF8C6A3A),
          iconAsset: AppIcons.hardware,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.hardware),
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String title,
    required String description,
    required Color color,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    final iconTint = color.withValues(alpha: 0.95);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Padding(
                padding: EdgeInsets.zero,
                child: SvgPicture.asset(
                  iconAsset,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(iconTint, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.8,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.6,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.28,
              ),
            ),
          ],
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
    final colors = context.appColors;
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
                  color: isActive ? colors.textPrimary : colors.borderStrong,
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
    final imageUrl = (advert.imageUrl ?? '').trim();
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.appColors.surfaceSecondary,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            )
          : const SizedBox.shrink(),
    );
  }
}
