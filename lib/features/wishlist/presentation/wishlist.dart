// wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

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
      return _buildEmptyStateContent();
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

  Widget _buildEmptyStateContent() {
    final colors =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
        ? AppThemeColors.dark
        : AppThemeColors.light;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Screen Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wishlist',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: colors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Empty state illustration area
            _buildEmptyStateIllustration(colors),

            const SizedBox(height: 70),

            // Empty state messages
            _buildEmptyStateMessages(colors),

            const SizedBox(height: 48),

            // CTA Button
            _buildKeepShoppingButton(colors),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIllustration(AppThemeColors colors) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          // Heart icon (using Flutter icon since no asset provided)
          Container(
            width: 105,
            height: 105,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Icon(Icons.favorite_border, size: 80, color: colors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateMessages(AppThemeColors colors) {
    return Column(
      children: [
        Text(
          'Nothing saved yet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: colors.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12),

        Text(
          'Your saved items drop here',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKeepShoppingButton(AppThemeColors colors) {
    return Center(
      child: SizedBox(
        width: 210,
        height: 57,
        child: ElevatedButton(
          onPressed: onKeepShoppingPressed ?? _defaultKeepShoppingPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.onAccent,
            elevation: 8,
            shadowColor: colors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
          child: const Text(
            'Keep Shopping',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }
}
