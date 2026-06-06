import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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


  /// WAWUAfrica services promo. The two-line WAWUAfrica brand logo stays fixed
  /// while the individual services (EasyBuy, Health Insurance, Pension, …) fade
  /// through, so every WAWUAfrica service is surfaced from the WAWUBeauty home.
  Widget _buildWawuServicesRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _WawuServicesStrip(onOpen: (path) => _openHub(context, path)),
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

/// A single WAWUAfrica service entry surfaced by [_WawuServicesStrip].
class _WawuService {
  const _WawuService({
    required this.label,
    required this.path,
    required this.icon,
    this.soon = false,
  });

  final String label;
  final String path;
  final IconData icon;
  final bool soon;
}

const List<_WawuService> _wawuServices = [
  _WawuService(
    label: 'EasyBuy',
    path: '/services/easybuy/apply',
    icon: Icons.shopping_bag_outlined,
  ),
  _WawuService(
    label: 'Health Insurance',
    path: '/services/insurance',
    icon: Icons.health_and_safety_outlined,
    soon: true,
  ),
  _WawuService(
    label: 'Pension',
    path: '/services/pension',
    icon: Icons.savings_outlined,
    soon: true,
  ),
  _WawuService(
    label: 'Banking',
    path: '/services/banking',
    icon: Icons.account_balance_outlined,
  ),
  _WawuService(
    label: 'Grants & Funding',
    path: '/services/grants',
    icon: Icons.volunteer_activism_outlined,
  ),
  _WawuService(
    label: 'CAC Registration',
    path: '/services/cac-registration/apply',
    icon: Icons.assignment_outlined,
  ),
  _WawuService(
    label: 'NEPC Registration',
    path: '/services/nepc-registration/apply',
    icon: Icons.public_outlined,
  ),
  _WawuService(
    label: 'Mentorship',
    path: '/services/mentors',
    icon: Icons.diversity_3_outlined,
  ),
];

/// WAWUAfrica services strip: the two-line brand logo stays fixed on the left
/// while the individual services fade/slide through automatically, cycling
/// through every service so each is surfaced from the WAWUBeauty home.
class _WawuServicesStrip extends StatefulWidget {
  final void Function(String path) onOpen;
  const _WawuServicesStrip({required this.onOpen});

  @override
  State<_WawuServicesStrip> createState() => _WawuServicesStripState();
}

class _WawuServicesStripState extends State<_WawuServicesStrip> {
  static const Duration _interval = Duration(milliseconds: 2800);
  static const int _slots = 3; // services shown (and animating) at once

  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // One fading service slot. Each of the [_slots] slots shows a different
  // service and they all advance (animate) together on every tick, cycling
  // through the whole list.
  Widget _slot(int i, AppThemeColors colors) {
    final service = _wawuServices[(_step * _slots + i) % _wawuServices.length];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onOpen(service.path),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.22),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Padding(
          key: ValueKey<String>('$i-${service.path}'),
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: _ServiceItem(service: service, colors: colors),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(WBRadius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed black two-row WAWUAfrica mark — opens the services home.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onOpen('/services'),
            child: Row(
              children: [
                Image.asset(
                  AppIcons.wawuAfricaMark,
                  height: 46,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Icon(Icons.arrow_outward, size: 16, color: colors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 1, color: colors.accentSoft),
          const SizedBox(height: 2),
          // Three services visible at once, all fading/cycling together.
          for (int i = 0; i < _slots; i++) _slot(i, colors),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.service,
    required this.colors,
  });

  final _WawuService service;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(service.icon, size: 22, color: colors.textPrimary),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            service.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WBTypography.body.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        if (service.soon) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(WBRadius.pill),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Icon(Icons.arrow_outward, size: 18, color: colors.textSecondary),
      ],
    );
  }
}
