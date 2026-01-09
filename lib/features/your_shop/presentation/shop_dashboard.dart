import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../app/router/app_router.dart';
import '../subfeatures/product/product_listing.dart';
import '../subfeatures/orders/orders.dart';
class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildShopHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildStatsRow(context),
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
              _buildOrdersTable(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dijee Stitches",
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
            "search Oja Ewa",
            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          label: "Products",
          count: "20",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductListingsScreen()),
            );
          },
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          label: "Orders",
          count: "100",
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

  Widget _buildOrdersTable() {
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
              Expanded(flex: 3, child: Text("Package", style: _headerStyle)),
              Expanded(flex: 2, child: Text("Status", style: _headerStyle)),
            ],
          ),
        ),
        // Table Rows
        _buildOrderRow("#hg5675894h", "Jan 6 2023", "Quick Quick", true),
        _buildOrderRow("#hg5675894h", "Jan 6 2023", "Quick Quick", false),
        _buildOrderRow("#hg5675894h", "Jan 6 2023", "Quick Quick", true),
      ],
    );
  }

  static const _headerStyle = TextStyle(fontSize: 10, color: Color(0xFF777F84));

  Widget _buildOrderRow(String no, String date, String package, bool isGrey) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: isGrey ? const Color(0xFFFBFBFB) : Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(no, style: _cellStyle)),
          Expanded(flex: 3, child: Text(date, style: _cellStyle)),
          Expanded(flex: 3, child: Text(package, style: _cellStyle)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3095CE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "In Process",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _cellStyle = TextStyle(fontSize: 12, color: Colors.black);
}