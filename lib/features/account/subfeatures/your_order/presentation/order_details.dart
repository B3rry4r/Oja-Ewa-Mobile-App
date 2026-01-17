// order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/orders/domain/order_models.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/orders/presentation/order_status_ui.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = (args is Map && args['orderId'] is int) ? args['orderId'] as int : null;

    if (orderId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8F1),
        body: SafeArea(child: Center(child: Text('Missing order id'))),
      );
    }

    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: orderAsync.when(
          loading: () => const Column(
            children: [
              AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
                title: Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF241508),
                  ),
                ),
              ),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (e, st) => Column(
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
                title: Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF241508),
                  ),
                ),
              ),
              Expanded(child: Center(child: Text('Failed to load order: $e'))),
            ],
          ),
          data: (data) {
            if (data.isEmpty) {
              return const Column(
                children: [
                  AppHeader(
                    backgroundColor: Color(0xFFFFF8F1),
                    iconColor: Color(0xFF241508),
                    title: Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: Text('Order not found'))),
                ],
              );
            }

            final order = OrderSummary.fromJson(data);

            // Build shipping address from available fields
            final shippingAddress = data['shipping_address'] as String? ?? data['address'] as String?;
            final shippingCity = data['shipping_city'] as String?;
            final shippingState = data['shipping_state'] as String?;
            final shippingCountry = data['shipping_country'] as String?;
            final shippingToParts = [
              shippingAddress,
              shippingCity,
              shippingState,
              shippingCountry,
            ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
            final shippingTo = shippingToParts.isEmpty ? null : shippingToParts.join(', ');

            return Column(
              children: [
                const AppHeader(
                  backgroundColor: Color(0xFFFFF8F1),
                  iconColor: Color(0xFF241508),
                  title: Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF241508),
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Order Information section
                        _buildOrderInformation(context, order),

                        const SizedBox(height: 16),

                        // Shipping Address section
                        _buildShippingAddress(shippingTo),

                        const SizedBox(height: 16),

                        // Items in Order section
                        _buildItemsInOrder(order.items),

                        const SizedBox(height: 16),

                        // Payment section
                        _buildPaymentDetails(order.totalPrice ?? 0, order.paymentReference),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderInformation(BuildContext context, OrderSummary order) {
    final orderedOn = order.createdAt != null
        ? '${order.createdAt!.day.toString().padLeft(2, '0')}/'
          '${order.createdAt!.month.toString().padLeft(2, '0')}/'
          '${order.createdAt!.year}'
        : '—';
    final orderNumber = order.orderNumber ?? '#${order.id}';
    final statusLabel = OrderStatusUi.label(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Information',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),

          const SizedBox(height: 16),

          // Ordered on
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ordered on',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF777F84),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                orderedOn,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Order Number with Copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Number',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF777F84),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: orderNumber));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF777F84),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF777F84),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(String? shippingTo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping to',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            (shippingTo == null || shippingTo.trim().isEmpty) ? 'Not provided' : shippingTo,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C4042),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsInOrder(List<OrderItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items in Order',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),

          const SizedBox(height: 16),

          for (int i = 0; i < items.length; i++) ...[
            _buildOrderItem(item: items[i]),
            if (i < items.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem({required OrderItem item}) {
    final img = item.product.image;
    final price = item.unitPrice ?? item.product.price ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: (img == null || img.isEmpty)
              ? const AppImagePlaceholder(width: 80, height: 68, borderRadius: 4)
              : Image.network(
                  img,
                  width: 80,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const AppImagePlaceholder(width: 80, height: 68, borderRadius: 4),
                ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0F1011),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                formatPrice(price),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '-',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C4042),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'X${item.quantity}',
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C4042),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(num total, String? paymentReference) {
    final subtotal = total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C4042),
            ),
          ),

          const SizedBox(height: 16),

          if (paymentReference != null && paymentReference.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Reference',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF3C4042),
                  ),
                ),
                Flexible(
                  child: Text(
                    paymentReference,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C4042),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
              Text(
                formatPrice(subtotal),
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shipping',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
              const Text(
                '₦0',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3C4042),
                ),
              ),
              Text(
                formatPrice(total),
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3C4042),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
