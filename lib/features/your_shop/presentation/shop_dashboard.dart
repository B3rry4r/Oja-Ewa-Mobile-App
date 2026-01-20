import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/domain/seller_status.dart';
import 'package:ojaewa/features/your_shop/presentation/controllers/seller_orders_controller.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/ai/presentation/controllers/ai_analytics_controller.dart';

import '../../../app/router/app_router.dart';
import '../subfeatures/product/product_listing.dart';
import '../subfeatures/orders/orders.dart';

class ShopDashboardScreen extends ConsumerWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerStatus = ref.watch(sellerStatusProvider);
    final processingOrders = ref.watch(sellerOrdersProvider('processing'));
    final allOrders = ref.watch(sellerOrdersProvider(null));
    final userId = ref.watch(userProfileProvider).value?.id.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main Brand Background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
              ),
              const SizedBox(height: 24),
              const Text(
                "Your Shop",
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              const SizedBox(height: 8),
              _buildShopHeader(context, sellerStatus),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildStatsRow(
                context,
                allOrders.maybeWhen(data: (o) => o.length, orElse: () => 0),
                0,
              ),
              const SizedBox(height: 16),
              // AI Analytics Button
              _buildAiAnalyticsButton(context, ref, userId),
              const SizedBox(height: 32),
              const Text(
                "Orders in Process",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2021),
                ),
              ),
              const SizedBox(height: 16),
              _buildOrdersTable(processingOrders),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context, SellerStatus? sellerStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Shop',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E2021),
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageShop),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: const Text(
              "Manage Shop",
              style: TextStyle(fontSize: 14, color: Color(0xFF301C0A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0xFF777F84), size: 20),
          SizedBox(width: 12),
          Text(
            "search Ojá-Ẹwà",
            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, int ordersCount, int productsCount) {
    return Row(
      children: [
        _buildStatCard(
          label: "Products",
          count: productsCount.toString(),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductListingsScreen()),
            );
          },
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          label: "Orders",
          count: ordersCount.toString(),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShopOrdersScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5E0CE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF777F84), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text(
                    "View",
                    style: TextStyle(fontSize: 10, color: Color(0xFF1E2021)),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF1E2021)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTable(AsyncValue<List<SellerOrder>> ordersAsync) {
    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Failed to load orders', style: TextStyle(color: Color(0xFF777F84)))),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No processing orders', style: TextStyle(color: Color(0xFF777F84)))),
          );
        }

        final dateFormat = DateFormat('MMM d');
        return Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              color: const Color(0xFFF5E0CE),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: Text("Order No", style: _headerStyle)),
                  Expanded(flex: 3, child: Text("Order Date", style: _headerStyle)),
                  Expanded(flex: 3, child: Text("Customer", style: _headerStyle)),
                  Expanded(flex: 2, child: Text("Status", style: _headerStyle)),
                ],
              ),
            ),
            // Table Rows
            ...orders.map((o) {
              return _buildOrderRow(
                '#${o.orderNumber}',
                dateFormat.format(o.createdAt),
                o.customerName ?? '—',
                o.status,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  static const _headerStyle = TextStyle(fontSize: 10, color: Color(0xFF777F84));

  Widget _buildOrderRow(String no, String date, String customer, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(no, style: _cellStyle)),
          Expanded(flex: 3, child: Text(date, style: _cellStyle)),
          Expanded(flex: 3, child: Text(customer, style: _cellStyle)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _statusLabel(status),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalyticsButton(BuildContext context, WidgetRef ref, String? userId) {
    return InkWell(
      onTap: () async {
        if (userId != null && userId.isNotEmpty) {
          await ref.read(sellerAnalyticsControllerProvider.notifier).initialize(userId);
        }
        if (context.mounted) {
          Navigator.of(context).pushNamed(AppRoutes.sellerAnalytics);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDAF40), Color(0xFFFFCC80)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.insights,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Analytics',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Smart inventory & trend predictions',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFF3095CE);
      case 'shipped':
        return const Color(0xFF2E7D32);
      case 'delivered':
        return const Color(0xFF70B673);
      case 'cancelled':
        return const Color(0xFFC95353);
      case 'pending':
      default:
        return const Color(0xFF777F84);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  static const _cellStyle = TextStyle(fontSize: 12, color: Colors.black);
}