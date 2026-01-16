import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/subfeatures/your_address/domain/address.dart';
import 'package:ojaewa/features/account/subfeatures/your_address/presentation/controllers/address_controller.dart';
import 'package:ojaewa/features/cart/domain/cart.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/cart/presentation/controllers/checkout_controller.dart';

/// Format number to 1 decimal place, removing trailing zeros
String _formatPrice(num value) {
  final formatted = value.toStringAsFixed(1);
  // Remove .0 if whole number
  if (formatted.endsWith('.0')) {
    return formatted.substring(0, formatted.length - 2);
  }
  return formatted;
}

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key, this.hasAddress = true});

  /// Whether there is a selected address (used for empty state vs selected state).
  final bool hasAddress;

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  static const _returnArgKey = 'returnTo';
  static const _returnToOrderConfirmation = 'orderConfirmation';

  @override
  Widget build(BuildContext context) {
    // Use optimistic cart for synced totals (updates when items are deleted/modified)
    final optimisticCart = ref.watch(optimisticCartProvider);
    final cartAsync = ref.watch(cartProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final isBusy = ref.watch(orderActionsProvider).isLoading;

    // Use optimistic cart if available, otherwise fall back to cartProvider
    final cart = optimisticCart ?? cartAsync.asData?.value;
    final isCartLoading = cartAsync.isLoading && optimisticCart == null;
    final hasCartError = cartAsync.hasError && optimisticCart == null;

    // Get selected/default address
    final addresses = addressesAsync.asData?.value ?? [];
    final selectedAddress = addresses.where((a) => a.isDefault).firstOrNull ?? 
                            (addresses.isNotEmpty ? addresses.first : null);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFF8F1),
              iconColor: const Color(0xFF241508),
              showActions: false,
              title: const Text(
                'Order confirmation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
              onBack: () => Navigator.of(context).maybePop(),
            ),

            Expanded(
              child: isCartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasCartError
                      ? const Center(child: Text('Failed to load cart'))
                      : cart == null || cart.items.isEmpty
                          ? const Center(child: Text('Cart is empty'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  _buildAddressSection(context, selectedAddress),
                                  const SizedBox(height: 32),
                                  _buildItemsSection(cart.items.length),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
            ),

            _buildOrderSummary(
              cart: cart,
              isBusy: isBusy, 
              onPlaceOrder: isBusy
                  ? null
                  : () async {
                      if (selectedAddress == null) {
                        AppSnackbars.showError(context, 'Please add a delivery address');
                        return;
                      }

                      final items = ref.read(checkoutOrderItemsProvider);
                      if (items.isEmpty) {
                        AppSnackbars.showError(context, 'Your cart is empty');
                        return;
                      }

                      try {
                        final link = await ref
                            .read(orderActionsProvider.notifier)
                            .createOrderAndPaymentLink(items: items);

                        final uri = Uri.tryParse(link.paymentUrl);
                        if (uri == null || link.paymentUrl.isEmpty) {
                          if (context.mounted) {
                            AppSnackbars.showError(context, 'Failed to generate payment link');
                          }
                          return;
                        }
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackbars.showError(context, 'Failed to create order: ${e.toString()}');
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, Address? address) {
    final hasAddress = address != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2021),
          ),
        ),
        const SizedBox(height: 12),
        if (!hasAddress)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'No address selected yet',
                    style: TextStyle(fontSize: 14, color: Color(0xFF777F84)),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(
                      AppRoutes.addEditAddress,
                      arguments: {_returnArgKey: _returnToOrderConfirmation},
                    );
                  },
                  child: const Text('Add address'),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await Navigator.of(context).pushNamed(
                AppRoutes.addresses,
                arguments: {_returnArgKey: _returnToOrderConfirmation},
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCCCCC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${address.fullName} ${address.phone}\n${address.addressLine}, ${address.city}, ${address.state}, \n${address.country} ${address.postCode}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3C4042),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, color: Color(0xFF777F84)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemsSection(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2021),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$count item(s)',
          style: const TextStyle(color: Color(0xFF777F84)),
        ),
      ],
    );
  }

  Widget _buildOrderSummary({
    required Cart? cart,
    required bool isBusy,
    required VoidCallback? onPlaceOrder,
  }) {
    final total = cart?.total ?? 0;

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
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFBFBFB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 14, color: Color(0xFFFBFBFB)),
                  ),
                  Text(
                    'N${_formatPrice(total)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onPlaceOrder,
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
                  child: Center(
                    child: isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFFBF5),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFBF5),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
