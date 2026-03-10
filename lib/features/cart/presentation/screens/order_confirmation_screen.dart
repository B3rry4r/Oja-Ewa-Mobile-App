import 'package:flutter/material.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
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
import 'package:ojaewa/features/cart/presentation/widgets/payment_method_sheet.dart';
import 'package:ojaewa/features/orders/data/orders_repository_impl.dart';
import 'package:ojaewa/features/orders/domain/logistics_models.dart';
import 'package:ojaewa/features/cart/presentation/screens/momo_payment_screen.dart';

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
  final Map<int, String> _selectedQuotesBySeller = {};

  @override
  Widget build(BuildContext context) {
    // Use optimistic cart for synced totals (updates when items are deleted/modified)
    final optimisticCart = ref.watch(optimisticCartProvider);
    final cartAsync = ref.watch(cartProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final isBusy = ref.watch(orderActionsProvider).isLoading;
    final checkoutItems = ref.watch(checkoutOrderItemsProvider);

    // Use optimistic cart if available, otherwise fall back to cartProvider
    final cart = optimisticCart ?? cartAsync.asData?.value;
    final isCartLoading = cartAsync.isLoading && optimisticCart == null;
    final hasCartError = cartAsync.hasError && optimisticCart == null;

    // Get selected/default address
    final addresses = addressesAsync.asData?.value ?? [];
    final selectedAddress =
        addresses.where((a) => a.isDefault).firstOrNull ??
        (addresses.isNotEmpty ? addresses.first : null);
    final logisticsRequest = ref.watch(
      logisticsQuoteRequestProvider(selectedAddress),
    );
    final shippingQuotesAsync = logisticsRequest == null
        ? const AsyncData<List<SellerShippingQuotes>>([])
        : ref.watch(logisticsQuotesProvider(logisticsRequest));

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
                          _buildShippingSection(
                            cart: cart,
                            quotesAsync: shippingQuotesAsync,
                          ),
                          const SizedBox(height: 32),
                          _buildItemsSection(cart.items.length),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),

            _buildOrderSummary(
              cart: cart,
              quotesAsync: shippingQuotesAsync,
              isBusy: isBusy,
              onPlaceOrder: isBusy
                  ? null
                  : () async {
                      if (selectedAddress == null) {
                        AppSnackbars.showError(
                          context,
                          'Please add a delivery address',
                        );
                        return;
                      }

                      if (checkoutItems.isEmpty) {
                        AppSnackbars.showError(context, 'Your cart is empty');
                        return;
                      }
                      final quoteGroups = shippingQuotesAsync.asData?.value;
                      if (shippingQuotesAsync.isLoading) {
                        AppSnackbars.showError(
                          context,
                          'Shipping options are still loading',
                        );
                        return;
                      }
                      if (shippingQuotesAsync.hasError || quoteGroups == null) {
                        AppSnackbars.showError(
                          context,
                          'Failed to load shipping options',
                        );
                        return;
                      }
                      if (quoteGroups.isEmpty) {
                        AppSnackbars.showError(
                          context,
                          'No shipping options available for this cart',
                        );
                        return;
                      }
                      final missingQuotes = quoteGroups
                          .where(
                            (group) =>
                                (_selectedQuotesBySeller[group
                                            .sellerProfileId] ??
                                        '')
                                    .isEmpty,
                          )
                          .toList();
                      if (missingQuotes.isNotEmpty) {
                        AppSnackbars.showError(
                          context,
                          'Choose one shipping option for each seller',
                        );
                        return;
                      }
                      final selectedQuotes = quoteGroups
                          .map(
                            (group) => SelectedShippingQuote(
                              sellerProfileId: group.sellerProfileId,
                              quoteReference:
                                  _selectedQuotesBySeller[group
                                      .sellerProfileId]!,
                            ),
                          )
                          .toList();

                      // Show payment method selection
                      final paymentMethod = await PaymentMethodSheet.show(
                        context,
                      );
                      if (paymentMethod == null) return;

                      if (!context.mounted) return;

                      try {
                        // Create order first (common for both payment methods)
                        final order = await ref
                            .read(ordersRepositoryProvider)
                            .createOrder(
                              items: checkoutItems,
                              addressId: selectedAddress.id,
                              shippingName: selectedAddress.fullName,
                              shippingPhone: selectedAddress.phone,
                              shippingAddress: selectedAddress.addressLine,
                              shippingCity: selectedAddress.city,
                              shippingState: selectedAddress.state,
                              shippingCountry: selectedAddress.country,
                              shippingZipCode: selectedAddress.postCode,
                              selectedQuotes: selectedQuotes,
                            );

                        if (!context.mounted) return;

                        if (paymentMethod == 'momo') {
                          // MoMo payment flow
                          await _handleMoMoPayment(
                            context,
                            ref,
                            order.id,
                            selectedAddress.phone,
                          );
                        } else {
                          // Paystack payment flow (original)
                          await _handlePaystackPayment(context, ref, order.id);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackbars.showError(
                            context,
                            'Failed to create order: ${e.toString()}',
                          );
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingSection({
    required Cart cart,
    required AsyncValue<List<SellerShippingQuotes>> quotesAsync,
  }) {
    final sellerNames = _sellerNamesById(cart);

    return quotesAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Shipping Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2021),
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(),
        ],
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load shipping options: $error',
            style: const TextStyle(color: Color(0xFFB3261E)),
          ),
        ],
      ),
      data: (groups) {
        _syncSelectedQuotes(groups);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2021),
              ),
            ),
            const SizedBox(height: 12),
            if (groups.isEmpty)
              const Text(
                'No shipping options available yet for this address.',
                style: TextStyle(color: Color(0xFF777F84)),
              ),
            for (final group in groups) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerNames[group.sellerProfileId] ??
                          'Seller #${group.sellerProfileId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final quote in group.quotes)
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: quote.quoteReference,
                        groupValue:
                            _selectedQuotesBySeller[group.sellerProfileId],
                        activeColor: const Color(0xFFFDAF40),
                        title: Text(quote.serviceName),
                        subtitle: Text(
                          [
                            quote.provider.toUpperCase(),
                            if (quote.estimatedDays != null)
                              '${quote.estimatedDays} day(s)',
                          ].join(' • '),
                        ),
                        secondary: Text(
                          formatPrice(quote.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedQuotesBySeller[group.sellerProfileId] =
                                value;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _syncSelectedQuotes(List<SellerShippingQuotes> groups) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final next = <int, String>{};
      for (final group in groups) {
        final existing = _selectedQuotesBySeller[group.sellerProfileId];
        final hasExisting = group.quotes.any(
          (quote) => quote.quoteReference == existing,
        );
        if (hasExisting && existing != null) {
          next[group.sellerProfileId] = existing;
          continue;
        }
        if (group.quotes.length == 1) {
          next[group.sellerProfileId] = group.quotes.first.quoteReference;
        }
      }
      final changed =
          next.length != _selectedQuotesBySeller.length ||
          next.entries.any(
            (entry) => _selectedQuotesBySeller[entry.key] != entry.value,
          );
      if (!changed) return;
      setState(() {
        _selectedQuotesBySeller
          ..clear()
          ..addAll(next);
      });
    });
  }

  Map<int, String> _sellerNamesById(Cart cart) {
    final names = <int, String>{};
    for (final item in cart.items) {
      final sellerId = item.product.sellerProfileId;
      if (sellerId == null || sellerId == 0) continue;
      final businessName = item.product.sellerBusinessName;
      if (businessName == null || businessName.isEmpty) continue;
      names[sellerId] = businessName;
    }
    return names;
  }

  Widget _buildAddressSection(BuildContext context, Address? address) {
    final hasAddress = address != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
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
                  const Icon(
                    Icons.keyboard_arrow_right,
                    color: Color(0xFF777F84),
                  ),
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
    required AsyncValue<List<SellerShippingQuotes>> quotesAsync,
    required bool isBusy,
    required VoidCallback? onPlaceOrder,
  }) {
    final subtotal = cart?.total ?? 0;
    final deliveryFee =
        quotesAsync.asData?.value.fold<num>(0, (sum, group) {
          final selectedQuoteReference =
              _selectedQuotesBySeller[group.sellerProfileId];
          final selectedQuote = group.quotes.firstWhere(
            (quote) => quote.quoteReference == selectedQuoteReference,
            orElse: () => const ShippingQuote(
              quoteReference: '',
              provider: '',
              serviceCode: '',
              serviceName: '',
              amount: 0,
              currency: 'NGN',
              estimatedDays: null,
              expiresAt: null,
            ),
          );
          return sum + selectedQuote.amount;
        }) ??
        0;
    final total = subtotal + deliveryFee;

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
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 14, color: Color(0xFFFBFBFB)),
                  ),
                  Text(
                    formatPrice(subtotal),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Delivery Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Fee',
                    style: TextStyle(fontSize: 14, color: Color(0xFFFBFBFB)),
                  ),
                  Text(
                    formatPrice(deliveryFee),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF8B6B4F), height: 1),
              const SizedBox(height: 12),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFBFBFB),
                    ),
                  ),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFDAF40),
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
                        color: const Color(0xFFFDAF40).withValues(alpha: 0.3),
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

  Future<void> _handlePaystackPayment(
    BuildContext context,
    WidgetRef ref,
    int orderId,
  ) async {
    try {
      final link = await ref
          .read(ordersRepositoryProvider)
          .createOrderPaymentLink(orderId: orderId);

      final uri = Uri.tryParse(link.paymentUrl);
      if (uri == null || link.paymentUrl.isEmpty) {
        if (context.mounted) {
          AppSnackbars.showError(context, 'Failed to generate payment link');
        }
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        AppSnackbars.showError(
          context,
          'Failed to initialize Paystack payment: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _handleMoMoPayment(
    BuildContext context,
    WidgetRef ref,
    int orderId,
    String phone,
  ) async {
    try {
      // Initialize MoMo payment
      final response = await ref
          .read(ordersRepositoryProvider)
          .initializeMoMoPayment(orderId: orderId, phone: phone);

      if (!context.mounted) return;

      // Navigate to MoMo payment screen with polling
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MoMoPaymentScreen(
            referenceId: response.referenceId,
            orderId: response.orderId,
            phone: phone,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackbars.showError(
          context,
          'Failed to initialize MoMo payment: ${e.toString()}',
        );
      }
    }
  }
}
