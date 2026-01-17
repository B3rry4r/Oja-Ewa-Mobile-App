import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/your_shop/presentation/controllers/seller_orders_controller.dart';

class ShopOrderDetailsScreen extends ConsumerWidget {
  const ShopOrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(sellerOrderDetailsProvider(orderId));
    final isActing = ref.watch(sellerOrderActionsProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            Expanded(
              child: orderAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load order',
                        style: TextStyle(color: Colors.grey[600]),
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
                data: (order) =>
                    _buildOrderDetails(context, ref, order, isActing),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    WidgetRef ref,
    SellerOrder order,
    bool isActing,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID Heading
          Text(
            '#${order.orderNumber}',
            style: const TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 8),
          // Status chip
          _buildStatusChip(order.status),
          const SizedBox(height: 30),

          // Details List
          _buildDetailTile("Order Date", dateFormat.format(order.createdAt)),
          if (order.customerName != null)
            _buildDetailTile("Customer", order.customerName!),
          if (order.customerPhone != null)
            _buildDetailTile("Phone", order.customerPhone!),
          if (order.shippingAddress != null)
            _buildDetailTile(
              "Shipping Address",
              order.shippingAddress!.fullAddress,
            ),

          const SizedBox(height: 20),
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildItemTile(item)),

          const SizedBox(height: 20),
          _buildDetailTile("Total", '₦${order.totalPrice.toStringAsFixed(0)}'),

          if (order.trackingNumber != null)
            _buildDetailTile("Tracking Number", order.trackingNumber!),

          const SizedBox(height: 40),

          // Action Buttons based on status
          _buildActionButtons(context, ref, order, isActing),
          const SizedBox(height: 40),
        ],
      ),
    );
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
        return {
          'label': 'Pending',
          'bgColor': const Color(0xFFE3F2FD),
          'textColor': const Color(0xFF1565C0),
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

  Widget _buildItemTile(SellerOrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Campton',
                    color: Color(0xFF241508),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}${item.size != null ? ' • Size: ${item.size}' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777F84),
                    fontFamily: 'Campton',
                  ),
                ),
                Text(
                  '₦${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: Color(0xFF241508),
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
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return const SizedBox.shrink(); // No actions for completed orders
    }

    return Column(
      children: [
        // Primary action based on status
        if (order.canAccept)
          _buildPrimaryButton(
            label: isActing ? 'Processing...' : 'Accept Order',
            onTap: isActing ? null : () => _acceptOrder(context, ref, order.id),
          ),
        if (order.canShip)
          _buildPrimaryButton(
            label: isActing ? 'Processing...' : 'Mark as Shipped',
            onTap: isActing
                ? null
                : () => _showShipDialog(context, ref, order.id),
          ),
        if (order.canDeliver)
          _buildPrimaryButton(
            label: isActing ? 'Processing...' : 'Mark as Delivered',
            onTap: isActing
                ? null
                : () => _deliverOrder(context, ref, order.id),
          ),

        const SizedBox(height: 16),

        // Cancel button (if applicable)
        if (order.canCancel)
          _buildSecondaryButton(
            label: 'Cancel Order',
            onTap: isActing
                ? null
                : () => _showCancelDialog(context, ref, order.id),
          ),
      ],
    );
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
    final reasonController = TextEditingController();
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CancelOrderModal',
      barrierColor: const Color(0xFF1E2021).withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: const Color(0xFF1E2021).withValues(alpha: 0.8),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Cancel Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF603814),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please provide a reason for cancellation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1E2021),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: reasonController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          color: Color(0xFF1E2021),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g., Out of stock',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Campton',
                            color: Color(0xFF777F84),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
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
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFCCCCCC),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF595F63),
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
                                borderRadius: BorderRadius.circular(8),
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

  Widget _buildPrimaryButton({required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFCCCCCC)
              : const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
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
          borderRadius: BorderRadius.circular(8),
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

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF777F84),
              fontFamily: 'Campton',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C4042),
              fontFamily: 'Campton',
            ),
          ),
        ],
      ),
    );
  }
}
