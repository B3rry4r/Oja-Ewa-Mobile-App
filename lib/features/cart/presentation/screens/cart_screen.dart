import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/cart/domain/cart.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';

/// Format number to 1 decimal place, removing trailing zeros
String _formatPrice(num value) {
  final formatted = value.toStringAsFixed(1);
  // Remove .0 if whole number
  if (formatted.endsWith('.0')) {
    return formatted.substring(0, formatted.length - 2);
  }
  return formatted;
}

/// Renamed/moved Shopping Bag screen. UI is unchanged.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the optimistic cart state instead of raw cartProvider
    final cart = ref.watch(optimisticCartProvider);
    final isInitialLoading = ref.watch(cartProvider).isLoading && cart == null;
    final hasError = ref.watch(cartProvider).hasError && cart == null;

    return Scaffold(
      backgroundColor: Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: const Color(0xFF603814),
              child: const AppHeader(
                backgroundColor: Color(0xFF603814),
                iconColor: Colors.white,
                showActions: false,
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: isInitialLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasError
                        ? const Center(child: Text('Failed to load cart'))
                        : cart == null
                            ? const Center(child: Text('Your cart is empty.'))
                            : _CartBody(cart: cart),
              ),
            ),
            _CheckoutSection(cart: cart),
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
              return _CartRow(key: ValueKey(item.id), item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItem = item;
    final product = cartItem.product;

    // Parse available sizes from product
    final availableSizes = product.size?.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() ?? [];

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
                    child: Image.network(
                      product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const AppImagePlaceholder(
                        width: 96,
                        height: 96,
                        borderRadius: 0,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
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
                      onPressed: () {
                        // Optimistic: remove immediately, revert on failure
                        ref.read(optimisticCartActionsProvider.notifier).removeItem(
                          context: context,
                          cartItemId: cartItem.id,
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF241508)),
                    ),
                  ],
                ),
                // Size selector
                if (availableSizes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showSizeSelector(context, ref, cartItem, availableSizes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Size: ${cartItem.selectedSize.isNotEmpty ? cartItem.selectedSize : "Select"}',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF3C4042)),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF3C4042)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${_formatPrice(cartItem.unitPrice ?? 0)}',
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
                            onTap: cartItem.quantity <= 1
                                ? null
                                : () {
                                    // Optimistic: update immediately
                                    ref.read(optimisticCartActionsProvider.notifier).updateQuantity(
                                      context: context,
                                      cartItemId: cartItem.id,
                                      newQuantity: cartItem.quantity - 1,
                                    );
                                  },
                            child: Icon(
                              Icons.remove,
                              size: 20,
                              color: cartItem.quantity <= 1 ? const Color(0xFFCCCCCC) : const Color(0xFF3C4042),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3C4042)),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              // Optimistic: update immediately
                              ref.read(optimisticCartActionsProvider.notifier).updateQuantity(
                                context: context,
                                cartItemId: cartItem.id,
                                newQuantity: cartItem.quantity + 1,
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

  void _showSizeSelector(BuildContext context, WidgetRef ref, CartItem cartItem, List<String> sizes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF241508),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                // Size options - full width list
                ...sizes.map((size) {
                  final isSelected = size == cartItem.selectedSize;
                  return InkWell(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      // Optimistic: update immediately
                      ref.read(optimisticCartActionsProvider.notifier).updateSize(
                        context: context,
                        cartItemId: cartItem.id,
                        newSize: size,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFDF3E7) : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              size,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: const Color(0xFF241508),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check, size: 20, color: Color(0xFFA15E22)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({required this.cart});

  final Cart? cart;

  @override
  Widget build(BuildContext context) {
    final total = cart?.total ?? 0;
    final isEmpty = cart == null || cart!.items.isEmpty;

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
                    '₦${_formatPrice(total)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFBFBFB)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('+ ₦2,000 delivery fee at checkout', style: TextStyle(fontSize: 12, color: Color(0xFFFBFBFB))),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pushNamed(AppRoutes.orderConfirmation);
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isEmpty ? const Color(0xFFCCCCCC) : const Color(0xFFFDAF40),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isEmpty
                        ? null
                        : [
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
