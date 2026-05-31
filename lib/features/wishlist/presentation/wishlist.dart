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
      return _buildEmptyStateContent(context);
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

  Widget _buildEmptyStateContent(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmptyStateIllustration(colors),
              const SizedBox(height: 28),
              _buildEmptyStateMessages(colors),
              const SizedBox(height: 28),
              _buildKeepShoppingButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateIllustration(AppThemeColors colors) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.favorite_border, size: 54, color: colors.accent),
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
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12),

        Text(
          'Products you save will show up here for quick access later.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKeepShoppingButton(AppThemeColors colors) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 54,
        child: ElevatedButton(
          onPressed: onKeepShoppingPressed ?? _defaultKeepShoppingPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.onAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          child: const Text(
            'Keep Shopping',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
