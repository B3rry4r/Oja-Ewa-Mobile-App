import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/features/your_shop/presentation/controllers/seller_orders_controller.dart';

import 'shop_order_details.dart';

class ShopOrdersScreen extends ConsumerStatefulWidget {
  const ShopOrdersScreen({super.key});

  @override
  ConsumerState<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends ConsumerState<ShopOrdersScreen> {
  String? _selectedStatus;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ordersAsync = ref.watch(
      sellerOrdersRealtimeProvider(_selectedStatus),
    );

    return AppPageScaffold(
      title: 'Orders',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 28),
          _buildFilterTabs(),
          const SizedBox(height: 32),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load orders',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(sellerOrdersProvider(_selectedStatus));
                        ref.invalidate(
                          sellerOrdersRealtimeProvider(_selectedStatus),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (orders) => _buildOrdersList(orders),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final colors = context.appColors;
    return Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.accent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search orders...",
                hintStyle: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab("All Orders", null),
          _buildTab("Pending", "pending_booking"),
          _buildTab("Booking Failed", "booking_failed"),
          _buildTab("Booked", "booked"),
          _buildTab("Processing", "processing"),
          _buildTab("Shipped", "shipped"),
          _buildTab("In Transit", "in_transit"),
          _buildTab("Delivered", "delivered"),
          _buildTab("Cancelled", "cancelled"),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String? status) {
    final colors = context.appColors;
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? colors.accent : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.onAccent : colors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<SellerOrder> orders) {
    final colors = context.appColors;
    final searchTerm = _searchController.text.toLowerCase();
    final filteredOrders = searchTerm.isEmpty
        ? orders
        : orders
              .where(
                (o) =>
                    o.orderNumber.toLowerCase().contains(searchTerm) ||
                    (o.customerName?.toLowerCase().contains(searchTerm) ??
                        false),
              )
              .toList();

    if (filteredOrders.isEmpty) {
      return const WBEmptyState(
        illustration: WBEmptyIllustration.noOrders,
        label: 'No orders found',
        sub: 'New orders for your shop will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(sellerOrdersProvider(_selectedStatus));
        ref.invalidate(sellerOrdersRealtimeProvider(_selectedStatus));
      },

      child: Column(
        children: [
          // Table Header
          Container(
            height: 40,
            color: colors.surfaceSecondary,
            child: const Row(
              children: [
                _Cell(text: "Order No", flex: 3, isHeader: true),
                _Cell(text: "Date", flex: 2, isHeader: true),
                _Cell(text: "Customer", flex: 3, isHeader: true),
                _Cell(text: "Status", flex: 2, isHeader: true),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final dateFormat = DateFormat('MMM d');
                return _OrderRow(
                  orderId: order.orderId,
                  orderNumber: '#${order.orderNumber}',
                  date: order.createdAt == null ? '—' : dateFormat.format(order.createdAt!),
                  customer: order.customerName ?? '—',
                  status: order.status,
                  backgroundColor: index.isEven
                      ? const Color(0xFFFBFBFB)
                      : const Color(0xFFF4F4F4),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final int orderId;
  final String orderNumber, date, customer, status;
  final Color backgroundColor;

  const _OrderRow({
    required this.orderId,
    required this.orderNumber,
    required this.date,
    required this.customer,
    required this.status,
    required this.backgroundColor,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_booking':
        return const Color(0xFF1565C0);
      case 'booking_failed':
        return const Color(0xFFC62828);
      case 'booked':
        return const Color(0xFF6A1B9A);
      case 'processing':
        return const Color(0xFF3095CE);
      case 'shipped':
        return const Color(0xFF2E7D32);
      case 'in_transit':
        return const Color(0xFF00897B);
      case 'delivered':
        return const Color(0xFF70B673);
      case 'cancelled':
        return const Color(0xFFC95353);
      default:
        return const Color(0xFF757575);
    }
  }

  String get _statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_booking':
        return 'Pending';
      case 'booking_failed':
        return 'Booking Failed';
      case 'booked':
        return 'Booked';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShopOrderDetailsScreen(orderId: orderId),
          ),
        );
      },
      child: Container(
        height: 48,
        color: backgroundColor,
        child: Row(
          children: [
            _Cell(text: orderNumber, flex: 3),
            _Cell(text: date, flex: 2),
            _Cell(text: customer, flex: 3),
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHeader;

  const _Cell({required this.text, required this.flex, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isHeader ? 10 : 12,
            fontWeight: FontWeight.w400,
            color: isHeader
                ? context.appColors.textTertiary
                : context.appColors.textPrimary.withValues(alpha: 0.97),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
