import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
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
    final ordersAsync = ref.watch(sellerOrdersProvider(_selectedStatus));

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 14),
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
                              Text('Failed to load orders', style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => ref.invalidate(sellerOrdersProvider(_selectedStatus)),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFFA15E22), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search orders...",
                hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontSize: 16, fontFamily: 'Campton'),
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
          _buildTab("Pending", "pending"),
          _buildTab("Processing", "processing"),
          _buildTab("Shipped", "shipped"),
          _buildTab("Delivered", "delivered"),
          _buildTab("Cancelled", "cancelled"),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF301C0A),
            fontSize: 14,
            fontFamily: 'Campton',
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<SellerOrder> orders) {
    final searchTerm = _searchController.text.toLowerCase();
    final filteredOrders = searchTerm.isEmpty
        ? orders
        : orders.where((o) =>
            o.orderNumber.toLowerCase().contains(searchTerm) ||
            (o.customerName?.toLowerCase().contains(searchTerm) ?? false)).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No orders found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(sellerOrdersProvider(_selectedStatus)),
      child: Column(
        children: [
          // Table Header
          Container(
            height: 40,
            color: const Color(0xFFF5E0CE),
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
                  orderId: order.id,
                  orderNumber: '#${order.orderNumber}',
                  date: dateFormat.format(order.createdAt),
                  customer: order.customerName ?? 'N/A',
                  status: order.status,
                  backgroundColor: index.isEven ? const Color(0xFFFBFBFB) : const Color(0xFFF4F4F4),
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
      case 'pending': return const Color(0xFF1565C0);
      case 'processing': return const Color(0xFF3095CE);
      case 'shipped': return const Color(0xFF2E7D32);
      case 'delivered': return const Color(0xFF70B673);
      case 'cancelled': return const Color(0xFFC95353);
      default: return const Color(0xFF757575);
    }
  }

  String get _statusLabel {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'processing': return 'Processing';
      case 'shipped': return 'Shipped';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ShopOrderDetailsScreen(orderId: orderId)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Campton'),
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
            color: isHeader ? const Color(0xFF777F84) : const Color(0xFF000000).withOpacity(0.97),
            fontFamily: 'Campton',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
