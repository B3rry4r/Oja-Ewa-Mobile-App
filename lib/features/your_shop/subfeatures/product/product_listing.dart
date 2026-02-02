import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/sort_sheet.dart';
import 'package:ojaewa/features/your_shop/data/seller_product_repository.dart';
import '../add_edit_product/add_edit_product.dart';
import '../add_edit_product/seller_category_selection.dart';
import 'domain/shop_product.dart';

import '../../../../core/widgets/confirmation_modal.dart';

final sellerProductsProvider = FutureProvider<List<ShopProduct>>((ref) async {
  final repo = ref.read(sellerProductRepositoryProvider);
  final productsJson = await repo.getMyProducts(perPage: 100);
  return productsJson.map(ShopProduct.fromJson).toList();
});

class ProductListingsScreen extends ConsumerStatefulWidget {
  const ProductListingsScreen({super.key});

  @override
  ConsumerState<ProductListingsScreen> createState() => _ProductListingsScreenState();
}

class _ProductListingsScreenState extends ConsumerState<ProductListingsScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Approved';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(sellerProductsProvider);

    return productsAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFFFF8F1),
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
              ),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
      error: (error, _) => _buildErrorState(context, error),
      data: (products) => _buildContent(context, products),
    );
  }

  Widget _buildContent(BuildContext context, List<ShopProduct> products) {
    final filteredProducts = _applyFilters(products);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Products Listings",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF241508),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${filteredProducts.length} Products",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E2021),
                          ),
                        ),
                        _buildAddProductButton(context),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFilterTabs(context),
                    const SizedBox(height: 24),
                    _buildProductTable(context, filteredProducts),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to category selection first, then to add product
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SellerCategorySelectionScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab("Approved", isActive: _selectedStatus == 'Approved'),
          const SizedBox(width: 8),
          _buildTab("Rejected", isActive: _selectedStatus == 'Rejected'),
          const SizedBox(width: 8),
          _buildTab("Pending", isActive: _selectedStatus == 'Pending'),
          const SizedBox(width: 8),
          _buildTab("All", isActive: _selectedStatus == 'All'),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.7),
          isScrollControlled: true,
          builder: (_) => const SortOverlay(),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              AppIcons.sort,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFF241508),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "Sort",
              style: TextStyle(fontSize: 14, color: Color(0xFF241508)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, {bool isActive = false}) {
    return InkWell(
      onTap: () => setState(() => _selectedStatus = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA15E22) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF301C0A),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<ShopProduct> _applyFilters(List<ShopProduct> products) {
    final query = _searchQuery.toLowerCase();
    final filteredByStatus = _selectedStatus == 'All'
        ? products
        : products.where((p) => p.status.toLowerCase() == _selectedStatus.toLowerCase()).toList();

    if (query.isEmpty) return filteredByStatus;

    return filteredByStatus
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildProductTable(BuildContext context, List<ShopProduct> products) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No products yet',
            style: TextStyle(fontSize: 16, color: Color(0xFF777F84)),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFF5E0CE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text("Name", style: _headerStyle)),
              Expanded(flex: 2, child: Text("Status", style: _headerStyle)),
              Expanded(flex: 3, child: Text("Actions", style: _headerStyle)),
            ],
          ),
        ),
        // Rows
        ...products.map((p) {
          final color = switch (p.status) {
            'Approved' => const Color(0xFF70B673),
            'Pending' => const Color(0xFFF9ECBD),
            'Rejected' => const Color(0xFFC95353),
            'In Process' => const Color(0xFF3095CE),
            _ => const Color(0xFF70B673),
          };
          final textColor = p.status == 'Pending' ? Colors.black : Colors.white;
          final isAlt = p.id.hashCode.isEven;
          return _buildProductRow(
            context,
            p,
            color,
            isAlt,
            textColor: textColor,
          );
        }),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFF777F84),
    fontWeight: FontWeight.bold,
  );

  Widget _buildProductRow(
    BuildContext context,
    ShopProduct product,
    Color statusColor,
    bool isAlt, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isAlt ? const Color(0xFFFBFBFB) : const Color(0xFFF4F4F4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              product.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.status,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildActionIcon(
                  context,
                  icon: Icons.edit_outlined,
                  label: "Edit",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(productId: product.id),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildActionIcon(
                  context,
                  icon: Icons.delete_outline,
                  label: "Delete",
                  onTap: () {
                    ConfirmationModal.show(
                      context,
                      title: 'Delete product',
                      message: 'Are you sure you want to delete this product?',
                      confirmLabel: 'Delete',
                      onConfirm: () {
                        // TODO: delete later
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3C4042)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF3C4042)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Failed to load products',
                        style: TextStyle(fontSize: 16, color: Color(0xFF777F84)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
