import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/orders/presentation/controllers/orders_controller.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Keep the existing filter tab UI (non-functional for now)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA15E22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'All orders',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFBFBFB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _OutlinedTab(label: 'Processing'),
                  const SizedBox(width: 8),
                  const _OutlinedTab(label: 'Shipped'),
                  const SizedBox(width: 8),
                  const _OutlinedTab(label: 'Delivered'),
                ],
              ),
            ),
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('Failed to load orders')),
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders yet'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final o = orders[index];
                      final status = (o.status ?? 'pending');
                      final statusColor = switch (status) {
                        'delivered' => const Color(0xFF70B673),
                        'shipped' => const Color(0xFF3095CE),
                        'processing' => const Color(0xFF3095CE),
                        'paid' => const Color(0xFF3095CE),
                        'cancelled' => const Color(0xFFCCCCCC),
                        _ => const Color(0xFF3095CE),
                      };

                      final hasReviewButton = status == 'delivered';
                      final itemCount = '${o.items.length} item${o.items.length == 1 ? '' : 's'}';
                      final totalAmount = 'N${(o.totalPrice ?? 0).toString()}';

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
                                        status,
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
                                  for (final _ in o.items.take(2)) ...[
                                    Container(
                                      width: 80,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD9D9D9),
                                        borderRadius: BorderRadius.circular(4),
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

class _OutlinedTab extends StatelessWidget {
  const _OutlinedTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          color: Color(0xFF301C0A),
        ),
      ),
    );
  }
}
