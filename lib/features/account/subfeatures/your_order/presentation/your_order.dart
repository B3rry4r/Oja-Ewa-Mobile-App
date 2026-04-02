import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/orders/presentation/order_status_ui.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ordersAsync = ref.watch(ordersRealtimeProvider);

    return AppPageScaffold(
      title: 'Your Orders',
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load orders')),
        data: (orders) {
          final filteredOrders = _selectedStatus == null
              ? orders
              : orders
                    .where(
                      (o) => (o.status ?? '').toLowerCase() == _selectedStatus,
                    )
                    .toList();

          if (filteredOrders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: filteredOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final status = order.status ?? 'pending';
              final statusColor = OrderStatusUi.color(status);
              final statusLabel = OrderStatusUi.label(status);
              final hasReviewButton = status == 'delivered';
              final itemCount =
                  '${order.items.length} item${order.items.length == 1 ? '' : 's'}';
              final totalAmount = formatPrice(order.totalPrice ?? 0);

              return InkWell(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.orderDetails,
                  arguments: {'orderId': order.id},
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(18),
                    color: colors.surfaceElevated,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final item in order.items.take(2)) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child:
                                  item.product.image == null ||
                                      (item.product.image ?? '').isEmpty
                                  ? const AppImagePlaceholder(
                                      width: 80,
                                      height: 68,
                                      borderRadius: 4,
                                    )
                                  : Image.network(
                                      item.product.image!,
                                      width: 80,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const AppImagePlaceholder(
                                              width: 80,
                                              height: 68,
                                              borderRadius: 4,
                                            );
                                          },
                                    ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemCount,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                'Total: $totalAmount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (hasReviewButton) ...[
                                InkWell(
                                  onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.reviewSubmission,
                                    arguments: {
                                      'type': 'order',
                                      'id': order.id,
                                    },
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 33,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: colors.accent),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Review',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Campton',
                                          fontWeight: FontWeight.w500,
                                          color: colors.accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              InkWell(
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.trackingOrder,
                                  arguments: {'orderId': order.id},
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 33,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.accent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Track',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Campton',
                                        fontWeight: FontWeight.w500,
                                        color: colors.onAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
