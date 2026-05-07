// ignore_for_file: unused_local_variable, unused_element, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:intl/intl.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/your_shop/presentation/controllers/seller_orders_controller.dart';

class ShopOrderDetailsScreen extends ConsumerWidget {
  const ShopOrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final orderAsync = ref.watch(sellerOrderDetailsProvider(orderId));
    final isActing = ref.watch(sellerOrderActionsProvider).isLoading;

    return AppPageScaffold(
      child: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load order',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(sellerOrderDetailsProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) => _buildOrderDetails(context, ref, order, isActing),
      ),
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    WidgetRef ref,
    SellerOrder order,
    bool isActing,
  ) {
    final colors = context.appColors;
    final dateFormat = DateFormat('MMM d, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID Heading
          Text(
            '#${order.orderNumber}',
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 8),
          // Status chip
          _buildStatusChip(order.status),
          const SizedBox(height: 30),

          // Details List
          _buildDetailTile(
            context,
            "Order Date",
            dateFormat.format(order.createdAt),
          ),
          if (order.shipmentId != 0)
            _buildDetailTile(
              context,
              "Shipment ID",
              order.shipmentId.toString(),
            ),
          if (order.customerName != null)
            _buildDetailTile(context, "Customer", order.customerName!),
          if (order.customerPhone != null)
            _buildDetailTile(context, "Phone", order.customerPhone!),
          if (order.provider != null || order.serviceName != null)
            _buildDetailTile(
              context,
              "Shipping Service",
              [
                if ((order.provider ?? '').isNotEmpty)
                  order.provider!.toUpperCase(),
                if ((order.serviceName ?? '').isNotEmpty) order.serviceName!,
              ].join(' • '),
            ),
          if (order.shippingFee != null)
            _buildDetailTile(
              context,
              "Shipping Fee",
              formatPriceFx(order.shippingFee!, order.currency),
            ),
          if ((order.paymentStatus ?? '').isNotEmpty)
            _buildDetailTile(context, "Payment Status", order.paymentStatus!),
          if ((order.returnRequestStatus ?? '').isNotEmpty) ...[
            _buildDetailTile(
              context,
              "Return Request",
              _buildReturnRequestLabel(order.returnRequestStatus!),
            ),
            if ((order.returnRequestReason ?? '').isNotEmpty)
              _buildDetailTile(
                context,
                "Return Reason",
                order.returnRequestReason!,
              ),
            if ((order.returnRequestRejectionReason ?? '').isNotEmpty)
              _buildDetailTile(
                context,
                "Return Rejection",
                order.returnRequestRejectionReason!,
              ),
            if ((order.returnRequestShipbubbleLabelUrl ?? '').isNotEmpty)
              _buildDetailTile(
                context,
                "Return Label",
                "Generated",
              ),
          ],
          if (order.shippingAddress != null)
            _buildDetailTile(
              context,
              "Shipping Address",
              order.shippingAddress!.fullAddress,
            ),

          const SizedBox(height: 20),
          Text(
            'Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildItemTile(context, item)),

          const SizedBox(height: 20),
          _buildDetailTile(context, "Total", formatPriceFx(order.totalPrice, order.currency)),

          if (order.trackingNumber != null)
            _buildDetailTile(context, "Tracking Number", order.trackingNumber!),

          const SizedBox(height: 40),

          // Action Buttons based on status
          _buildActionButtons(context, ref, order, isActing),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _buildReturnRequestLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_review':
        return 'Under review';
      case 'approved':
        return 'Approved, awaiting return';
      case 'return_in_transit':
        return 'Return in transit';
      case 'refund_pending':
        return 'Refund pending';
      case 'refunded':
        return 'Refunded';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Widget _buildStatusChip(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: config['textColor'] as Color,
          fontFamily: 'Campton',
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_booking':
        return {
          'label': 'Pending',
          'bgColor': const Color(0xFFE3F2FD),
          'textColor': const Color(0xFF1565C0),
        };
      case 'booking_failed':
        return {
          'label': 'Booking Failed',
          'bgColor': const Color(0xFFFFEBEE),
          'textColor': const Color(0xFFC62828),
        };
      case 'booked':
        return {
          'label': 'Booked',
          'bgColor': const Color(0xFFF3E5F5),
          'textColor': const Color(0xFF6A1B9A),
        };
      case 'processing':
        return {
          'label': 'Processing',
          'bgColor': const Color(0xFFFFF1CC),
          'textColor': const Color(0xFF856404),
        };
      case 'shipped':
        return {
          'label': 'Shipped',
          'bgColor': const Color(0xFFE8F5E9),
          'textColor': const Color(0xFF2E7D32),
        };
      case 'in_transit':
        return {
          'label': 'In Transit',
          'bgColor': const Color(0xFFE0F2F1),
          'textColor': const Color(0xFF00897B),
        };
      case 'delivered':
        return {
          'label': 'Delivered',
          'bgColor': const Color(0xFFD4EDDA),
          'textColor': const Color(0xFF155724),
        };
      case 'cancelled':
        return {
          'label': 'Cancelled',
          'bgColor': const Color(0xFFFFEBEE),
          'textColor': const Color(0xFFC62828),
        };
      default:
        return {
          'label': status,
          'bgColor': const Color(0xFFEEEEEE),
          'textColor': const Color(0xFF757575),
        };
    }
  }

  Widget _buildItemTile(BuildContext context, SellerOrderItem item) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          if (item.productImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.productImage!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const AppImagePlaceholder(
                  width: 60,
                  height: 60,
                  borderRadius: 8,
                ),
              ),
            )
          else
            const AppImagePlaceholder(width: 60, height: 60, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Campton',
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}${item.size != null ? ' • Size: ${item.size}' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textTertiary,
                    fontFamily: 'Campton',
                  ),
                ),
                Text(
                  formatPriceFx(item.price, order.currency),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    SellerOrder order,
    bool isActing,
  ) {
    // Order status management is now handled by admin
    // Sellers can only view order details
    return const SizedBox.shrink();
  }

  Future<void> _acceptOrder(
    BuildContext context,
    WidgetRef ref,
    int orderId,
  ) async {
    try {
      await ref.read(sellerOrderActionsProvider.notifier).acceptOrder(orderId);
      if (context.mounted) {
        AppSnackbars.showSuccess(context, 'Order accepted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbars.showError(context, 'Failed to accept order: $e');
      }
    }
  }

  Future<void> _showShipDialog(
    BuildContext context,
    WidgetRef ref,
    int orderId,
  ) async {
    final trackingController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ship Order'),
        content: TextField(
          controller: trackingController,
          decoration: const InputDecoration(
            labelText: 'Tracking Number (optional)',
            hintText: 'Enter tracking number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ship'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await ref
            .read(sellerOrderActionsProvider.notifier)
            .shipOrder(
              orderId,
              trackingNumber: trackingController.text.isNotEmpty
                  ? trackingController.text
                  : null,
            );
        if (context.mounted) {
          AppSnackbars.showSuccess(context, 'Order marked as shipped');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbars.showError(context, 'Failed to ship order: $e');
        }
      }
    }
  }

  Future<void> _deliverOrder(
    BuildContext context,
    WidgetRef ref,
    int orderId,
  ) async {
    try {
      await ref.read(sellerOrderActionsProvider.notifier).deliverOrder(orderId);
      if (context.mounted) {
        AppSnackbars.showSuccess(context, 'Order marked as delivered');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbars.showError(
          context,
          'Failed to mark order as delivered: $e',
        );
      }
    }
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    int orderId,
  ) async {
    final colors = context.appColors;
    final reasonController = TextEditingController();
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CancelOrderModal',
      barrierColor: colors.shadow.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        final colors = context.appColors;
        return Scaffold(
          backgroundColor: colors.shadow.withValues(alpha: 0.82),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Cancel Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please provide a reason for cancellation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: reasonController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g., Out of stock',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Campton',
                            color: colors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: colors.border),
                              ),
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                    fontFamily: 'Campton',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(true),
                            child: Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC95353),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel Order',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFBF5),
                                    fontFamily: 'Campton',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result == true && context.mounted) {
      if (reasonController.text.isEmpty) {
        AppSnackbars.showError(
          context,
          'Please provide a reason for cancellation',
        );
        return;
      }
      try {
        await ref
            .read(sellerOrderActionsProvider.notifier)
            .cancelOrder(orderId, reasonController.text);
        if (context.mounted) {
          AppSnackbars.showSuccess(context, 'Order cancelled');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbars.showError(context, 'Failed to cancel order: $e');
        }
      }
    }
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    VoidCallback? onTap,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: onTap == null ? colors.borderStrong : colors.accent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: onTap == null ? colors.textSecondary : colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFC95353)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC95353),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, String label, String value) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              fontFamily: 'Campton',
            ),
          ),
        ],
      ),
    );
  }
}
