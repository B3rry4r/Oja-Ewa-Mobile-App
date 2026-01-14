// wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import '../../../app/router/app_router.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF603814), // #603814
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with buttons
            _buildHeader(context),

            // Main Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1), // #FFF8F1
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppBottomNavBar.height,
                  ),
                  child: wishlist.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFFDAF40)),
                      ),
                    ),
                    error: (e, st) => Center(
                      child: Text(
                        UiErrorMessage.from(e),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    data: (items) => _buildWishlistContent(
                      context,
                      ref,
                      items,
                      actions.isLoading,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 104,
      color: const Color(0xFF603814),
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                HeaderIconButton(
                  asset: AppIcons.notification,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notifications),
                  iconColor: Colors.white,
                ),
                const SizedBox(width: 8),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
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
        const SizedBox(height: 30),

        // Screen Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Wishlist',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: Color(0xFF241508),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      builder: (_) => ProductDetailsScreen(productId: int.tryParse(product.id) ?? 0),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Screen Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wishlist',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508), // #241508
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Empty state illustration area
            _buildEmptyStateIllustration(),

            const SizedBox(height: 70),

            // Empty state messages
            _buildEmptyStateMessages(),

            const SizedBox(height: 48),

            // CTA Button
            _buildKeepShoppingButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIllustration() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E0CE), // #F5E0CE
              borderRadius: BorderRadius.circular(12),
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
            child: const Icon(
              Icons.favorite_border,
              size: 80,
              color: Color(0xFF603814), // Using theme color for icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateMessages() {
    return const Column(
      children: [
        // Main message
        Text(
          'Nothing saved yet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: Color(0xFF241508), // #241508
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12),

        // Sub message
        Text(
          'Your saved items drop here',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: Color(0xFF1E2021), // #1E2021
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKeepShoppingButton() {
    return Center(
      child: SizedBox(
        width: 210,
        height: 57,
        child: ElevatedButton(
          onPressed: onKeepShoppingPressed ?? _defaultKeepShoppingPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFDAF40), // #FDAF40
            foregroundColor: const Color(0xFFFFFBF5), // #FFFBF5
            elevation: 8,
            shadowColor: const Color(0xFFFDAF40).withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
