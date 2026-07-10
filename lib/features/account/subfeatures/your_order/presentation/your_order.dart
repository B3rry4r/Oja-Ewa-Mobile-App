import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/orders/presentation/order_status_ui.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _selectedStatus;
  int? _reorderingOrderId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    // Prefetch a little before hitting the bottom.
    if (current >= max - 250) {
      ref.read(ordersRealtimeProvider.notifier).loadMore();
    }
  }

  Future<void> _reorder(int orderId) async {
    setState(() => _reorderingOrderId = orderId);
    try {
      final count =
          await ref.read(orderActionsProvider.notifier).reorder(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'Re-added $count item${count == 1 ? '' : 's'} to your cart'
                : 'Nothing to reorder',
          ),
        ),
      );
      if (count > 0) {
        Navigator.of(context).pushNamed(AppRoutes.cart);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reorder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _reorderingOrderId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ordersAsync = ref.watch(ordersRealtimeProvider);

    return AppPageScaffold(
      // Body is a ListView/GridView: it needs a bounded height and scrolls itself.
      scrollable: false,
      title: 'Your Orders',
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load orders')),
        data: (ordersState) {
          final orders = ordersState.orders;
          final filteredOrders = _selectedStatus == null
              ? orders
              : orders
                    .where(
                      (o) => (o.status ?? '').toLowerCase() == _selectedStatus,
                    )
                    .toList();

          if (filteredOrders.isEmpty) {
            return const WBEmptyState(
              illustration: WBEmptyIllustration.noOrders,
              label: 'No orders yet',
              sub: 'Your orders will show up here once you check out.',
            );
          }

          // Append a trailing loader row while the next page is loading.
          final showLoader = ordersState.isLoadingMore;
          final itemCount = filteredOrders.length + (showLoader ? 1 : 0);

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= filteredOrders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final order = filteredOrders[index];
              final status = order.status ?? 'pending';
              final statusColor = OrderStatusUi.color(status);
              final statusLabel = OrderStatusUi.label(status);
              final hasReviewButton = status == 'delivered';
              final itemCount =
                  '${order.items.length} item${order.items.length == 1 ? '' : 's'}';
              final totalAmount = formatPriceFx(order.totalPrice ?? 0, order.currency);

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
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                'Total: $totalAmount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
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
                                onTap: _reorderingOrderId == null
                                    ? () => _reorder(order.id)
                                    : null,
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
                                    child: _reorderingOrderId == order.id
                                        ? SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colors.accent,
                                            ),
                                          )
                                        : Text(
                                            'Reorder',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: colors.accent,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                        fontWeight: FontWeight.w500,
                                        color: colors.onAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                              ),
                            ),
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
