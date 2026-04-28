// order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  _buildShipments(context, ref, effectiveOrder, effectiveOrder.shipments),
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
    WidgetRef ref,
    OrderSummary order,
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
            _buildShipmentRow(context, ref, order, shipments[i]),
            if (i < shipments.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildShipmentRow(
    BuildContext context,
    WidgetRef ref,
    OrderSummary order,
    ShipmentSummary shipment,
  ) {
    final colors = context.appColors;
    final provider = shipment.provider?.toUpperCase() ?? 'PROVIDER';
    final serviceName = shipment.serviceName ?? 'Shipping service';
    final status = OrderStatusUi.label(shipment.status);
    final returnRequest = shipment.returnRequest;
    final canRequestReturn =
        shipment.canRequestReturn && returnRequest == null;

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
        if (shipment.returnDeadlineAt != null) ...[
          const SizedBox(height: 4),
          Text(
            'Return deadline: ${DateFormat('MMM d, yyyy h:mm a').format(shipment.returnDeadlineAt!.toLocal())}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: colors.textSecondary,
            ),
          ),
        ],
        if (returnRequest != null) ...[
          const SizedBox(height: 8),
          _buildReturnRequestChip(context, returnRequest),
          const SizedBox(height: 8),
          if ((returnRequest.reason ?? '').isNotEmpty)
            Text(
              'Reason: ${returnRequest.reason}',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                color: colors.textSecondary,
              ),
            ),
          if ((returnRequest.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Rejection: ${returnRequest.rejectionReason}',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                color: colors.textSecondary,
              ),
            ),
          ],
          if ((returnRequest.shipbubbleReturnLabelUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                final url = Uri.tryParse(returnRequest.shipbubbleReturnLabelUrl!);
                if (url == null) return;
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              child: Text(
                'Open return label',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Campton',
                  color: colors.accent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          if ((returnRequest.buyerReturnTrackingNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Return tracking: ${returnRequest.buyerReturnTrackingNumber}',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                color: colors.textSecondary,
              ),
            ),
          ],
          if (returnRequest.status == 'approved') ...[
            const SizedBox(height: 12),
            Text(
              'Approved. Use the return label to send the item back, then tap below once it has been handed to the courier.',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showShipBackDialog(
                  context,
                  ref,
                  order.id,
                  shipment.id,
                  returnRequest.id,
                ),
                child: const Text('Mark Shipped Back'),
              ),
            ),
          ],
        ] else if (canRequestReturn) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showReturnDialog(
                context,
                ref,
                order.id,
                shipment.id,
              ),
              child: const Text('Request Return / Refund'),
            ),
          ),
        ],
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

  Widget _buildReturnRequestChip(
    BuildContext context,
    ShipmentReturnRequestSummary request,
  ) {
    final status = (request.status ?? 'pending_review').toLowerCase();
    final config = switch (status) {
      'approved' => (
          label: 'Return approved',
          background: const Color(0xFFE8F5E9),
          foreground: const Color(0xFF2E7D32),
        ),
      'return_in_transit' => (
          label: 'Returned in transit',
          background: const Color(0xFFE0F2F1),
          foreground: const Color(0xFF00897B),
        ),
      'rejected' => (
          label: 'Return rejected',
          background: const Color(0xFFFFEBEE),
          foreground: const Color(0xFFC62828),
        ),
      'refund_pending' => (
          label: 'Refund pending',
          background: const Color(0xFFFFF1CC),
          foreground: const Color(0xFF856404),
        ),
      'refunded' => (
          label: 'Refunded',
          background: const Color(0xFFE3F2FD),
          foreground: const Color(0xFF1565C0),
        ),
      _ => (
          label: 'Return under review',
          background: const Color(0xFFE0F2F1),
          foreground: const Color(0xFF00897B),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w600,
          color: config.foreground,
        ),
      ),
    );
  }

  Future<void> _showReturnDialog(
    BuildContext context,
    WidgetRef ref,
    int orderId,
    int shipmentId,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Return'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Explain why you want to return this item',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) {
      return;
    }

    if (controller.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a reason')),
        );
      }
      return;
    }

    try {
      await ref.read(orderActionsProvider.notifier).requestReturn(
            orderId: orderId,
            shipmentId: shipmentId,
            reason: controller.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return request submitted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit return request: $e')),
        );
      }
    }
  }

  Future<void> _showShipBackDialog(
    BuildContext context,
    WidgetRef ref,
    int orderId,
    int shipmentId,
    int returnRequestId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Shipped Back'),
        content: const Text(
          'Confirm that you have handed the return package to the courier. Shipbubble details are already attached by the backend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(orderActionsProvider.notifier).shipReturnBack(
            orderId: orderId,
            shipmentId: shipmentId,
            returnRequestId: returnRequestId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return shipment marked')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark return shipment: $e')),
        );
      }
    }
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
