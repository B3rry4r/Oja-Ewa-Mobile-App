import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/cart/domain/cart.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';

/// Renamed/moved Shopping Bag screen. UI is unchanged.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    // IMPORTANT: Avoid infinite-loader feel when cartProvider is invalidated.
    // If we have previous data while a refresh is happening, keep showing it.
    final cart = cartAsync.asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(iconColor: Colors.white, showActions: false),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Stack(
                  children: [
                    if (cart == null)
                      cartAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => const Center(child: Text('Failed to load cart')),
                        data: (loaded) => _CartBody(cart: loaded),
                      )
                    else
                      _CartBody(cart: cart),

                    // Small loader overlay when refreshing/reloading.
                    if (cart != null && cartAsync.isLoading)
                      const Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                      ),
                  ],
                ),
              ),
            ),
            _CheckoutSection(cartAsync: cartAsync),
          ],
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    if (cart.items.isEmpty) {
      return const Center(
        child: Text(
          'Your cart is empty.',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E2021),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: Text(
            'My Bag',
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cart.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartRow(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsBusy = ref.watch(cartActionsProvider).isLoading;

    final cartItem = item;
    final product = cartItem.product;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 122,
            height: 152,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.image == null
                ? const Center(
                    child: AppImagePlaceholder(
                      width: 96,
                      height: 96,
                      borderRadius: 0,
                      backgroundColor: Colors.transparent,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product.image!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF241508)),
                      ),
                    ),
                    IconButton(
                      onPressed: actionsBusy
                          ? null
                          : () async {
                              await ref.read(cartActionsProvider.notifier).removeItem(cartItemId: cartItem.id);
                            },
                      icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF241508)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'N${(cartItem.unitPrice ?? 0).toString()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF241508)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: actionsBusy || cartItem.quantity <= 1
                                ? null
                                : () {
                                    ref.read(cartActionsProvider.notifier).updateQuantity(
                                          cartItemId: cartItem.id,
                                          quantity: cartItem.quantity - 1,
                                        );
                                  },
                            child: const Icon(Icons.remove, size: 20, color: Color(0xFF3C4042)),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3C4042)),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: actionsBusy
                                ? null
                                : () {
                                    ref.read(cartActionsProvider.notifier).updateQuantity(
                                          cartItemId: cartItem.id,
                                          quantity: cartItem.quantity + 1,
                                        );
                                  },
                            child: const Icon(Icons.add, size: 20, color: Color(0xFF3C4042)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSection extends ConsumerWidget {
  const _CheckoutSection({required this.cartAsync});

  final AsyncValue cartAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = cartAsync.asData?.value?.total ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF603814),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFFBFBFB)),
                  ),
                  Text(
                    'N$total',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFBFBFB)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Delivery fee not included yet', style: TextStyle(fontSize: 12, color: Color(0xFFFBFBFB))),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.orderConfirmation);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDAF40),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFDAF40).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFFBF5))),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
