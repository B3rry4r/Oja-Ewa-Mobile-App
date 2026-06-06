// wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/app/router/app_router.dart';

import 'package:ojaewa/core/widgets/product_card.dart';
import '../../product_detail/presentation/product_detail_screen.dart';
import '../domain/wishlist_item.dart';
import 'controllers/wishlist_controller.dart';
import '_wishlist_adapter.dart';

class WishlistScreen extends ConsumerWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onKeepShoppingPressed;

  const WishlistScreen({
    super.key,
    this.onBackPressed,
    this.onFilterPressed,
    this.onSettingsPressed,
    this.onKeepShoppingPressed,
  });

  void _defaultKeepShoppingPressed() {
    // no-op (kept to preserve existing behavior)
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final actions = ref.watch(wishlistActionsProvider);

    return AppPageScaffold(
      title: 'Wishlist',
      showBack: false,
      includeBottomNavSpacing: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppBottomNavBar.height),
        child: wishlist.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(UiErrorMessage.from(e), textAlign: TextAlign.center),
          ),
          data: (items) =>
              _buildWishlistContent(context, ref, items, actions.isLoading),
        ),
      ),
    );
  }

  Widget _buildWishlistContent(
    BuildContext context,
    WidgetRef ref,
    List<WishlistItem> items,
    bool isBusy,
  ) {
    // Map backend wishlist items to existing ProductCard UI.
    final wishlistProducts = items
        .where((w) => w.type == WishlistableType.product)
        .map(toUiProduct)
        .toList();

    if (wishlistProducts.isEmpty) {
      final token = ref.watch(accessTokenProvider);
      final isGuest = token == null || token.isEmpty;
      return _buildEmptyStateContent(context, isGuest);
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 6,
              // Fixed tile height prevents large-screen gaps.
              mainAxisExtent: 248,
            ),
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = wishlistProducts[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(
                        productId: int.tryParse(product.id) ?? 0,
                      ),
                    ),
                  );
                },
                onFavoriteTap: isBusy
                    ? () {}
                    : () {
                        // Remove from wishlist
                        try {
                          ref
                              .read(wishlistActionsProvider.notifier)
                              .removeItem(
                                type: WishlistableType.product,
                                id: int.tryParse(product.id) ?? 0,
                              )
                              .then((_) {
                                if (!context.mounted) return;
                                AppSnackbars.showSuccess(
                                  context,
                                  'Removed from wishlist',
                                );
                              })
                              .catchError((e) {
                                if (!context.mounted) return;
                                AppSnackbars.showError(
                                  context,
                                  UiErrorMessage.from(e),
                                );
                              });
                        } catch (e) {
                          if (!context.mounted) return;
                          AppSnackbars.showError(
                            context,
                            UiErrorMessage.from(e),
                          );
                        }
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateContent(BuildContext context, bool isGuest) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              WBEmptyIllustration.noProducts,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              placeholderBuilder: (_) =>
                  const SizedBox(width: 200, height: 200),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.wishlistEmpty,
              style: WBTypography.section.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isGuest
                  ? 'Sign in to see saved items.'
                  : context.l10n.wishlistEmptySub,
              style: WBTypography.secondary.copyWith(
                color: WBColors.fgSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (isGuest)
              WBButton(
                label: 'Sign in',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
              )
            else
              WBButton(
                label: context.l10n.wishlistKeepShopping,
                onPressed: onKeepShoppingPressed ?? _defaultKeepShoppingPressed,
              ),
          ],
        ),
      ),
    );
  }
}
