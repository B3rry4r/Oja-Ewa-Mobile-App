import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';
import 'package:ojaewa/features/orders/presentation/order_status_ui.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _selectedStatus; // null means all

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFF8F1),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'Your Orders',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusTab(
                      label: 'All orders',
                      isSelected: _selectedStatus == null,
                      onTap: () => setState(() => _selectedStatus = null),
                    ),
                    const SizedBox(width: 8),
                    _StatusTab(
                      label: 'Processing',
                      isSelected: _selectedStatus == 'processing',
                      onTap: () => setState(() => _selectedStatus = 'processing'),
                    ),
                    const SizedBox(width: 8),
                    _StatusTab(
                      label: 'Shipped',
                      isSelected: _selectedStatus == 'shipped',
                      onTap: () => setState(() => _selectedStatus = 'shipped'),
                    ),
                    const SizedBox(width: 8),
                    _StatusTab(
                      label: 'Delivered',
                      isSelected: _selectedStatus == 'delivered',
                      onTap: () => setState(() => _selectedStatus = 'delivered'),
                    ),
                    const SizedBox(width: 8),
                    _StatusTab(
                      label: 'Cancelled',
                      isSelected: _selectedStatus == 'cancelled',
                      onTap: () => setState(() => _selectedStatus = 'cancelled'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('Failed to load orders')),
                data: (orders) {
                  final filteredOrders = _selectedStatus == null
                      ? orders
                      : orders.where((o) => (o.status ?? '').toLowerCase() == _selectedStatus).toList();

                  if (filteredOrders.isEmpty) {
                    return const Center(child: Text('No orders yet'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final o = filteredOrders[index];
                      final status = (o.status ?? 'pending');
                      final statusColor = OrderStatusUi.color(status);
                      final statusLabel = OrderStatusUi.label(status);

                      final hasReviewButton = status == 'delivered';
                      final itemCount = '${o.items.length} item${o.items.length == 1 ? '' : 's'}';
                      final totalAmount = '₦${(o.totalPrice ?? 0).toString()}';

                      return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.orderDetails,
                          arguments: {'orderId': o.id},
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCCCCCC)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${o.id}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Campton',
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF3C4042),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Campton',
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF3C4042),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (final item in o.items.take(2)) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: item.product.image == null || (item.product.image ?? '').isEmpty
                                          ? const AppImagePlaceholder(width: 80, height: 68, borderRadius: 4)
                                          : Image.network(
                                              item.product.image!,
                                              width: 80,
                                              height: 68,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const AppImagePlaceholder(width: 80, height: 68, borderRadius: 4);
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
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'Campton',
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF595F63),
                                        ),
                                      ),
                                      Text(
                                        'Total: $totalAmount',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'Campton',
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF595F63),
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
                                            arguments: {'type': 'order', 'id': o.id},
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            height: 33,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFFDAF40)),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Review',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Campton',
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFFDAF40),
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
                                          arguments: {'orderId': o.id},
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          height: 33,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFDAF40),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Track',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Campton',
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFFFFBF5),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: isSelected ? const Color(0xFFFBFBFB) : const Color(0xFF301C0A),
          ),
        ),
      ),
    );
  }
}
