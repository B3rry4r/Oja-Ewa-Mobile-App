import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/adverts/domain/advert.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/adverts/presentation/controllers/adverts_controller.dart';
import 'package:ojaewa/features/search/presentation/search_screen.dart';

import '../../../app/router/app_router.dart';

/// Beauty-flavoured hero taglines, mirroring WAWUBasket's randomised hero.
const List<({String accent, String muted})> _beautyTaglines = [
  (accent: 'Glow up.', muted: 'Shop African beauty'),
  (accent: 'Look good.', muted: 'Feel the culture'),
  (accent: 'Fresh drops.', muted: 'Curated for you'),
  (accent: 'Beauty meets craft.', muted: 'Discover makers'),
  (accent: 'Your style.', muted: 'Pan-African market'),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static Widget _padded(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 140),
          children: [
            _padded(_buildHeader(context)),
            const SizedBox(height: 22),
            _padded(const WBRandomTagline(pairs: _beautyTaglines)),
            const SizedBox(height: 22),
            _padded(_buildSearchBar(context)),
            const SizedBox(height: 22),
            _padded(_buildServicesRow(context)),
            const SizedBox(height: 24),
            _buildAdvertsOrFallback(context, ref),
            const SizedBox(height: 28),
            _padded(
              Text(
                context.l10n.homeShopByCategory,
                style: WBTypography.section.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCategoryGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: WBColors.bgSecondary,
          borderRadius: BorderRadius.circular(WBRadius.input),
        ),
        child: Row(
          children: [
            const WBIcon(WBIconName.search, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.homeSearchHint,
                overflow: TextOverflow.ellipsis,
                style: WBTypography.body.copyWith(
                  color: WBColors.fgPlaceholder,
                  fontSize: 16,
                ),
              ),
            ),
          ],
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
          const WBWordmark(height: 24),

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
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
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
      loading: () => const _AdvertLoadingSkeleton(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: _AdvertFadeCarousel.aspectRatio,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: WBColors.surfaceDark,
            borderRadius: BorderRadius.all(Radius.circular(WBRadius.card)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  context.l10n.homeDiscoverTitle,
                  style: WBTypography.section.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.homeDiscoverSub,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: WBTypography.secondary.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceShortcut(
            context: context,
            iconAsset: AppIcons.cacRegistration,
            label: 'CAC',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.cacServices),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildServiceShortcut(
            context: context,
            iconAsset: AppIcons.nepcRegistration,
            label: 'NEPC',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.nepcServices),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildServiceShortcut(
            context: context,
            iconAsset: AppIcons.adsPlacement,
            label: 'Adverts',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.advertPlacements),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildServiceShortcut(
            context: context,
            iconAsset: AppIcons.verifiedBadges,
            label: 'Badges',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.badgeVerifications),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceShortcut({
    required BuildContext context,
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
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
          description: 'Fabrics & prints',
          color: const Color(0xFFC7853D),
          iconAsset: AppIcons.market,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.market),
        ),
        // Beauty
        _buildCategoryItem(
          context: context,
          title: 'Afro Beauty',
          description: 'General beauty',
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
          description: 'Creatives',
          color: const Color(0xFFCC8E5B),
          iconAsset: AppIcons.music,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.music),
        ),
        // Schools
        _buildCategoryItem(
          context: context,
          title: 'Education',
          description: 'Schools',
          color: const Color(0xFFD39A54),
          iconAsset: AppIcons.schools,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.schools),
        ),
        // Hardware
        _buildCategoryItem(
          context: context,
          title: 'Hardware',
          description: 'Creative tools',
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
              width: 90,
              height: 90,
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.8,
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

class _AdvertLoadingSkeleton extends StatefulWidget {
  const _AdvertLoadingSkeleton();

  @override
  State<_AdvertLoadingSkeleton> createState() => _AdvertLoadingSkeletonState();
}

class _AdvertLoadingSkeletonState extends State<_AdvertLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = colors.surfaceSecondary.withValues(alpha: 0.9);
    final highlight = colors.surfaceElevated.withValues(alpha: 1);
    final shimmerBand = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.72);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slide = (_controller.value * 2) - 1;
          return AspectRatio(
            aspectRatio: _AdvertFadeCarousel.aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
                gradient: LinearGradient(
                  begin: Alignment(-1.8 + slide, -0.3),
                  end: Alignment(0.2 + slide, 0.3),
                  colors: [base, shimmerBand, highlight, shimmerBand, base],
                  stops: const [0.0, 0.24, 0.5, 0.76, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 110,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 180,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 140,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceSecondary,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                _AdvertImagePlaceholder(colors: colors),
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    final expected = loadingProgress.expectedTotalBytes;
                    final loaded = loadingProgress.cumulativeBytesLoaded;
                    final progress = expected == null || expected == 0
                        ? 0.0
                        : (loaded / expected).clamp(0.0, 1.0);
                    final blurSigma = 16 - (progress * 14);
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _AdvertImagePlaceholder(colors: colors),
                        Opacity(
                          opacity: 0.28 + (progress * 0.5),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: blurSigma,
                              sigmaY: blurSigma,
                            ),
                            child: child,
                          ),
                        ),
                      ],
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _AdvertImagePlaceholder(colors: colors),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class _AdvertImagePlaceholder extends StatelessWidget {
  const _AdvertImagePlaceholder({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceSecondary,
            colors.surfaceElevated.withValues(alpha: 0.92),
            colors.surfaceSecondary,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.26),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
