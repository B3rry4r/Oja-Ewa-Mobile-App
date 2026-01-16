import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/sort_sheet.dart';
import '../add_edit_product/add_edit_product.dart';
import 'data/mock_shop_products.dart';
import 'domain/shop_product.dart';

import '../../../../core/widgets/confirmation_modal.dart';
class ProductListingsScreen extends StatelessWidget {
  const ProductListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10),
            child: Row(
              children: [
                _buildCircularButton(Icons.notifications_none_outlined),
                const SizedBox(width: 8),
                _buildCircularButton(Icons.settings_outlined),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                const Text(
                  "20 Products",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2021),
                  ),
                ),
                _buildAddProductButton(context),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildFilterTabs(context),
            const SizedBox(height: 24),
            _buildProductTable(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Icon(icon, size: 20, color: Colors.black),
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
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
            color: const Color(0xFFFDAF40).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Text(
        "Add Product",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    ),
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
            "search Oja Ewa",
            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSortButton(context),
          const SizedBox(width: 8),
          _buildTab("Approved", isActive: true),
          const SizedBox(width: 8),
          _buildTab("Rejected"),
          const SizedBox(width: 8),
          _buildTab("Pending"),
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
          barrierColor: Colors.black.withOpacity(0.7),
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
    return Container(
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
    );
  }

  Widget _buildProductTable(BuildContext context) {
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
        ...mockShopProducts.map((p) {
          final color = switch (p.status) {
            'Approved' => const Color(0xFF70B673),
            'Pending' => const Color(0xFFF9ECBD),
            'Rejected' => const Color(0xFFC95353),
            'In Process' => const Color(0xFF3095CE),
            _ => const Color(0xFF70B673),
          };
          final textColor = p.status == 'Pending' ? Colors.black : Colors.white;
          final isAlt = p.id.hashCode.isEven;
          return _buildProductRow(context, p, color, isAlt, textColor: textColor);
        }),
      ],
    );
  }

  static const _headerStyle = TextStyle(fontSize: 10, color: Color(0xFF777F84), fontWeight: FontWeight.bold);

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
            child: Text(product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
                  style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
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
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF3C4042))),
        ],
      ),
    );
  }
}