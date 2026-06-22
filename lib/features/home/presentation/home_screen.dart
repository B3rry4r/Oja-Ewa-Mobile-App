import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/home/presentation/widgets/orbital_categories.dart';
import 'package:ojaewa/features/home/presentation/widgets/quick_action.dart';
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
            const SizedBox(height: 20),
            _padded(const WBRandomTagline(pairs: _beautyTaglines)),
            const SizedBox(height: 20),
            _padded(_buildSearchBar(context)),
            const SizedBox(height: 28),
            _padded(_buildQuickActions(context, ref)),
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

  /// Home quick-actions row, mirroring WAWUBasket's (same icon set).
  /// Beauty Kits is guest-accessible; Track / Reorder require login and prompt
  /// sign-in for guests (using the just-added gating pattern).
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    void requireAuth(String message, String route) {
      final token = ref.read(accessTokenProvider);
      if (token == null || token.isEmpty) {
        AppSnackbars.showError(context, message);
        Navigator.of(context).pushNamed(AppRoutes.signIn);
        return;
      }
      Navigator.of(context).pushNamed(route);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        QuickAction(
          icon: WBIconName.star,
          label: 'Beauty Kits',
          // Browsing kits is guest-accessible.
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.beautyKits),
        ),
        QuickAction(
          icon: WBIconName.pin,
          label: 'Track',
          onTap: () =>
              requireAuth('Please sign in to track orders', AppRoutes.orders),
        ),
        QuickAction(
          icon: WBIconName.basket,
          label: 'Reorder',
          onTap: () =>
              requireAuth('Please sign in to reorder', AppRoutes.orders),
        ),
        QuickAction(
          icon: WBIconName.bell,
          label: 'Updates',
          onTap: () => requireAuth(
            'Please sign in to see updates',
            AppRoutes.notifications,
          ),
        ),
      ],
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
