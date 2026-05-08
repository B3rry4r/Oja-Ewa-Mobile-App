import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/your_shop/data/seller_product_repository.dart';
import '../add_edit_product/add_edit_product.dart';
import '../add_edit_product/seller_category_selection.dart';
import 'domain/shop_product.dart';

import '../../../../core/widgets/confirmation_modal.dart';

final sellerProductsProvider = FutureProvider<List<ShopProduct>>((ref) async {
  final repo = ref.read(sellerProductRepositoryProvider);
  try {
    debugPrint('ProductListingScreen: Fetching seller products...');
    final productsJson = await repo.getMyProducts(perPage: 100);
    debugPrint(
      'ProductListingScreen: Received ${productsJson.length} products from API',
    );
    final products = productsJson.map(ShopProduct.fromJson).toList();
    debugPrint(
      'ProductListingScreen: Successfully parsed ${products.length} ShopProduct objects',
    );
    return products;
  } catch (e, st) {
    debugPrint('ProductListingScreen: Error fetching products: $e');
    debugPrint('ProductListingScreen: Stack trace: $st');
    rethrow;
  }
});

class ProductListingsScreen extends ConsumerStatefulWidget {
  const ProductListingsScreen({super.key});

  @override
  ConsumerState<ProductListingsScreen> createState() =>
      _ProductListingsScreenState();
}

class _ProductListingsScreenState extends ConsumerState<ProductListingsScreen> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(sellerProductsProvider);

    return productsAsync.when(
      loading: () => const AppPageScaffold(
        title: 'Products Listings',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _buildErrorState(context, error),
      data: (products) => _buildContent(context, products),
    );
  }

  Widget _buildContent(BuildContext context, List<ShopProduct> products) {
    final colors = context.appColors;
    final filteredProducts = _applyFilters(products);

    return AppPageScaffold(
      title: 'Products Listings',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${filteredProducts.length} Products",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
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
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        // Navigate to category selection first, then to add product
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SellerCategorySelectionScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          "Add Product",
          style: TextStyle(color: colors.onAccent, fontWeight: FontWeight.w600),
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

  Widget _buildTab(String label, {bool isActive = false}) {
    final colors = context.appColors;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = label),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? colors.accent : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: isActive ? null : Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? colors.onAccent : colors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<ShopProduct> _applyFilters(List<ShopProduct> products) {
    return _selectedStatus == 'All'
        ? products
        : products
              .where(
                (p) => p.status.toLowerCase() == _selectedStatus.toLowerCase(),
              )
              .toList();
  }

  Widget _buildProductTable(BuildContext context, List<ShopProduct> products) {
    final colors = context.appColors;
    if (products.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No products yet',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          final textColor = p.status == 'Pending'
              ? colors.onAccent
              : Colors.white;
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
    fontWeight: FontWeight.bold,
  );

  Widget _buildProductRow(
    BuildContext context,
    ShopProduct product,
    Color statusColor,
    bool isAlt, {
    Color textColor = Colors.white,
  }) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isAlt ? colors.surfaceElevated : colors.surfaceSecondary,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              product.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
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
                  borderRadius: BorderRadius.circular(999),
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
                  onTap: () => _deleteProduct(context, product),
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
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(BuildContext context, ShopProduct product) {
    ConfirmationModal.show(
      context,
      title: 'Delete product',
      message:
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      onConfirm: () => _performDelete(context, product),
    );
  }

  Future<void> _performDelete(BuildContext context, ShopProduct product) async {
    try {
      debugPrint('Deleting product: ${product.id} - ${product.name}');

      final repo = ref.read(sellerProductRepositoryProvider);
      await repo.deleteProduct(int.parse(product.id));

      debugPrint('Product deleted successfully');

      // Refresh the product list
      ref.invalidate(sellerProductsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting product: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: ${e.toString()}'),
          backgroundColor: Color(0xFFC95353),
        ),
      );
    }
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'Products Listings',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load products',
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
