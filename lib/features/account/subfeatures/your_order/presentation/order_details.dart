// order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/orders/domain/order_models.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/orders/presentation/order_status_ui.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = (args is Map && args['orderId'] is int)
        ? args['orderId'] as int
        : null;

    if (orderId == null) {
      return AppPageScaffold(
        title: 'Order Details',
        child: const Center(child: Text('Missing order id')),
      );
    }

    final orderAsync = ref.watch(orderDetailsProvider(orderId));
    final statusOverrides = ref.watch(orderStatusOverridesProvider);

    return AppPageScaffold(
      title: 'Order Details',
      child: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load order: $e')),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('Order not found'));
          }

          final order = OrderSummary.fromJson(data);
          final overrideStatus = statusOverrides[order.id];
          final effectiveOrder = overrideStatus == null
              ? order
              : OrderSummary(
                  id: order.id,
                  orderNumber: order.orderNumber,
                  totalPrice: order.totalPrice,
                  deliveryFee: order.deliveryFee,
                  status: overrideStatus,
                  paymentStatus: order.paymentStatus,
                  paymentReference: order.paymentReference,
                  trackingNumber: order.trackingNumber,
                  createdAt: order.createdAt,
                  items: order.items,
                  shipments: order.shipments,
                );

          // Build shipping address from available fields
          final shippingAddress =
              data['shipping_address'] as String? ?? data['address'] as String?;
          final shippingCity = data['shipping_city'] as String?;
          final shippingState = data['shipping_state'] as String?;
          final shippingCountry = data['shipping_country'] as String?;
          final shippingToParts =
              [shippingAddress, shippingCity, shippingState, shippingCountry]
                  .whereType<String>()
                  .where((part) => part.trim().isNotEmpty)
                  .toList();
          final shippingTo = shippingToParts.isEmpty
              ? null
              : shippingToParts.join(', ');

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: [
                _buildOrderInformation(context, effectiveOrder),
                const SizedBox(height: 16),
                _buildShippingAddress(context, shippingTo),
                const SizedBox(height: 16),
                _buildItemsInOrder(context, order.items),
                const SizedBox(height: 16),
                if (effectiveOrder.shipments.isNotEmpty) ...[
                  _buildShipments(context, effectiveOrder.shipments),
                  const SizedBox(height: 16),
                ],
                _buildPaymentDetails(
                  context,
                  effectiveOrder.totalPrice ?? 0,
                  effectiveOrder.deliveryFee,
                  effectiveOrder.paymentStatus,
                  effectiveOrder.paymentReference,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInformation(BuildContext context, OrderSummary order) {
    final colors = context.appColors;
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
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Information',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Ordered on
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ordered on',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                orderedOn,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
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
                  Text(
                    'Order Number',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: orderNumber));
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Copied')));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
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
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(BuildContext context, String? shippingTo) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping to',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            (shippingTo == null || shippingTo.trim().isEmpty)
                ? 'Not provided'
                : shippingTo,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsInOrder(BuildContext context, List<OrderItem> items) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items in Order',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          for (int i = 0; i < items.length; i++) ...[
            _buildOrderItem(context: context, item: items[i]),
            if (i < items.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required BuildContext context,
    required OrderItem item,
  }) {
    final colors = context.appColors;
    final img = item.product.image;
    final price = item.unitPrice ?? item.product.price ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: (img == null || img.isEmpty)
              ? const AppImagePlaceholder(
                  width: 80,
                  height: 68,
                  borderRadius: 4,
                )
              : Image.network(
                  img,
                  width: 80,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const AppImagePlaceholder(
                        width: 80,
                        height: 68,
                        borderRadius: 4,
                      ),
                ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                formatPrice(price),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'X${item.quantity}',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShipments(
    BuildContext context,
    List<ShipmentSummary> shipments,
  ) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipments',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < shipments.length; i++) ...[
            _buildShipmentRow(context, shipments[i]),
            if (i < shipments.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildShipmentRow(BuildContext context, ShipmentSummary shipment) {
    final colors = context.appColors;
    final provider = shipment.provider?.toUpperCase() ?? 'PROVIDER';
    final serviceName = shipment.serviceName ?? 'Shipping service';
    final status = OrderStatusUi.label(shipment.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$provider • $serviceName',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Status: $status',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Campton',
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Shipping Fee: ${formatPrice(shipment.shippingFee ?? 0)}',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Campton',
            color: colors.textSecondary,
          ),
        ),
        if ((shipment.trackingNumber ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Tracking Number: ${shipment.trackingNumber}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentDetails(
    BuildContext context,
    num total,
    num? deliveryFee,
    String? paymentStatus,
    String? paymentReference,
  ) {
    final colors = context.appColors;
    final subtotal = deliveryFee == null ? total : (total - deliveryFee);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (paymentReference != null && paymentReference.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Reference',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                Flexible(
                  child: Text(
                    paymentReference,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
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
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                formatPrice(subtotal < 0 ? 0 : subtotal),
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                formatPrice(deliveryFee ?? 0),
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          if (paymentStatus != null && paymentStatus.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Status',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  paymentStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                formatPrice(total),
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
