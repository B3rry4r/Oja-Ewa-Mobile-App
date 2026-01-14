import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/shopping_bag/presentation/controllers/checkout_controller.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key, this.hasAddress = true});

  /// Whether there is a selected address (used for empty state vs selected state).
  final bool hasAddress;

  @override
  ConsumerState<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends ConsumerState<OrderConfirmationScreen> {
  static const _returnArgKey = 'returnTo';
  static const _returnToOrderConfirmation = 'orderConfirmation';

  late bool _hasAddress;

  @override
  void initState() {
    super.initState();
    _hasAddress = widget.hasAddress;
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final isBusy = ref.watch(orderActionsProvider).isLoading;

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
              child: cartAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('Failed to load cart')),
                data: (cart) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildAddressSection(context),
                        const SizedBox(height: 32),
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 32),
                        _buildItemsSection(cart.items.length),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),

            _buildOrderSummary(
              cartAsync: cartAsync,
              isBusy: isBusy,
              onPlaceOrder: isBusy
                  ? null
                  : () async {
                      if (!_hasAddress) return;

                      final items = ref.read(checkoutOrderItemsProvider);
                      if (items.isEmpty) return;

                      final link = await ref.read(orderActionsProvider.notifier).createOrderAndPaymentLink(items: items);

                      final uri = Uri.tryParse(link.paymentUrl);
                      if (uri == null) return;
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E2021)),
        ),
        const SizedBox(height: 12),
        if (!_hasAddress)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('No address selected yet', style: TextStyle(fontSize: 14, color: Color(0xFF777F84))),
                ),
                TextButton(
                  onPressed: () async {
                    final updated = await Navigator.of(context).pushNamed(
                      AppRoutes.addEditAddress,
                      arguments: {
                        _returnArgKey: _returnToOrderConfirmation,
                      },
                    );
                    if (updated == true) {
                      setState(() => _hasAddress = true);
                    }
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
              final updated = await Navigator.of(context).pushNamed(
                AppRoutes.addresses,
                arguments: {
                  _returnArgKey: _returnToOrderConfirmation,
                },
              );
              if (updated == true) {
                setState(() => _hasAddress = true);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCCCCC)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Sanusi Sulat 08102718764\nRoyal Anchor, Abuja, FCT, \nNigeria 900187',
                      style: TextStyle(fontSize: 16, color: Color(0xFF3C4042), height: 1.5),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Color(0xFF777F84)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E2021))),
        const SizedBox(height: 12),
        Container(
          height: 88,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFCCCCCC))),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.radio_button_checked, color: Color(0xFFA15E22)),
              SizedBox(width: 16),
              Text('Pay with cards', style: TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 64,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFCCCCCC))),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.radio_button_unchecked, color: Color(0xFF777F84)),
              SizedBox(width: 16),
              Text('Pay with Bank Transfer', style: TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E2021))),
        const SizedBox(height: 12),
        Text('$count item(s)', style: const TextStyle(color: Color(0xFF777F84))),
      ],
    );
  }

  Widget _buildOrderSummary({required AsyncValue cartAsync, required bool isBusy, required VoidCallback? onPlaceOrder}) {
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
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFFBFBFB))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 14, color: Color(0xFFFBFBFB))),
                  Text('N$total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFBFBFB))),
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
                    child: Text(
                      isBusy ? 'Processing...' : 'Place Order',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFFBF5)),
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
