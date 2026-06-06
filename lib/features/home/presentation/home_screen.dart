import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/constants/app_urls.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/home/presentation/widgets/orbital_categories.dart';
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

  /// Renders a category/service artwork asset full-colour (no tint). Uses
  /// the SVG renderer for .svg brand art and the raster loader for .png.
  static Widget _artwork(String asset) {
    final isSvg = asset.toLowerCase().endsWith('.svg');
    return isSvg
        ? SvgPicture.asset(asset, fit: BoxFit.contain)
        : Image.asset(asset, fit: BoxFit.contain);
  }

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
            const SizedBox(height: 20),
            _padded(const WBRandomTagline(pairs: _beautyTaglines)),
            const SizedBox(height: 20),
            _padded(_buildSearchBar(context)),
            const SizedBox(height: 24),
            _buildWawuServicesRow(context),
            const SizedBox(height: 28),
            _padded(
              Text(
                context.l10n.homeShopByCategory,
                style: WBTypography.section.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildOrbitalCategories(context),
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
          const WBWordmark(height: 30),

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


  /// Horizontal row of WAWUAfrica service shortcuts that open the WAWUAfrica
  /// hub web platform. The first button is the WAWUAfrica brand (two-line
  /// logo) opening the hub services home; the rest open specific services.
  Widget _buildWawuServicesRow(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'WAWUAfrica services',
              style: WBTypography.section.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(WBRadius.card),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildWawuServiceButton(
                    context: context,
                    label: 'WAWUAfrica',
                    logoAsset: AppIcons.wawuAfricaLogo,
                    onTap: () => _openHub(context, '/services'),
                  ),
                ),
                Expanded(
                  child: _buildWawuServiceButton(
                    context: context,
                    label: 'EasyBuy',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => _openHub(context, '/services/easybuy/apply'),
                  ),
                ),
                Expanded(
                  child: _buildWawuServiceButton(
                    context: context,
                    label: 'Health\nInsurance',
                    icon: Icons.health_and_safety_outlined,
                    soon: true,
                    onTap: () => _openHub(context, '/services/insurance'),
                  ),
                ),
                Expanded(
                  child: _buildWawuServiceButton(
                    context: context,
                    label: 'Pension',
                    icon: Icons.savings_outlined,
                    soon: true,
                    onTap: () => _openHub(context, '/services/pension'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWawuServiceButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    String? logoAsset,
    IconData? icon,
    bool soon = false,
  }) {
    final colors = context.appColors;
    final Widget art = logoAsset != null
        ? Padding(
            padding: const EdgeInsets.all(4),
            child: _artwork(logoAsset),
          )
        : Icon(icon, size: 28, color: colors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 52,
                  width: 52,
                  child: Center(child: art),
                ),
                if (soon)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
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

  Future<void> _openHub(BuildContext context, String path) async {
    final uri = Uri.parse('$wawuAfricaHubUrl$path');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WAWUAfrica')),
      );
    }
  }

  Widget _buildOrbitalCategories(BuildContext context) {
    return OrbitalCategorySelector(
      categories: [
        OrbitalCategory(
          id: 'textiles',
          label: 'Textiles',
          iconAsset: AppIcons.market,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.market),
        ),
        OrbitalCategory(
          id: 'afro-beauty',
          label: 'Afro Beauty',
          iconAsset: AppIcons.beauty,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.beauty),
        ),
        OrbitalCategory(
          id: 'footwear-bags',
          label: 'Footwear/Bags',
          iconAsset: AppIcons.brands,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.brands),
        ),
        OrbitalCategory(
          id: 'art-market',
          label: 'Art Market',
          iconAsset: AppIcons.music,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.music),
        ),
        OrbitalCategory(
          id: 'education',
          label: 'Education',
          iconAsset: AppIcons.schools,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.schools),
        ),
        OrbitalCategory(
          id: 'hardware',
          label: 'Hardware',
          iconAsset: AppIcons.hardware,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.hardware),
        ),
      ],
    );
  }
}
