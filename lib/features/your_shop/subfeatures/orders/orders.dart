import 'package:flutter/material.dart';

import 'shop_order_details.dart';

class ShopOrdersScreen extends StatelessWidget {
  const ShopOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              _buildAppBar(),
              const SizedBox(height: 13),
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
              Expanded(child: _buildOrdersTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        _buildIconBox(Icons.arrow_back_ios_new),
        const Spacer(),
        _buildIconBox(Icons.notifications_none),
        const SizedBox(width: 4),
        _buildIconBox(Icons.person_outline),
      ],
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF241508)),
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
          const Text(
            "search Oja Ewa",
            style: TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 16,
              fontFamily: 'Campton',
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
          _buildTab("All Orders", isSelected: true),
          _buildTab("In Process"),
          _buildTab("Delivered"),
          _buildTab("Cancelled"),
        ],
      ),
    );
  }

  Widget _buildTab(String label, {bool isSelected = false}) {
    return Container(
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
    );
  }

  Widget _buildOrdersTable() {
    return Column(
      children: [
        // Table Header
        Container(
          height: 40,
          color: const Color(0xFFF5E0CE),
          child: const Row(
            children: [
              _Cell(text: "Order No", flex: 3, isHeader: true),
              _Cell(text: "Order Date", flex: 3, isHeader: true),
              _Cell(text: "Processing", flex: 3, isHeader: true),
              _Cell(text: "Status", flex: 2, isHeader: true),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView(
            children: [
              _OrderRow(
                id: "#hg5675894h",
                date: "Jan 6 2023",
                time: "Quick Quick",
                status: "In Process",
                statusColor: const Color(0xFF3095CE),
                backgroundColor: const Color(0xFFFBFBFB),
              ),
              _OrderRow(
                id: "#hg5675894h",
                date: "Jan 6 2023",
                time: "Quick Quick",
                status: "Delivered",
                statusColor: const Color(0xFF70B673),
                backgroundColor: const Color(0xFFF4F4F4),
              ),
              _OrderRow(
                id: "#hg5675894h",
                date: "Jan 6 2023",
                time: "Quick Quick",
                status: "Cancelled",
                statusColor: const Color(0xFFC95353),
                backgroundColor: const Color(0xFFFBFBFB),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String id, date, time, status;
  final Color statusColor;
  final Color backgroundColor;

  const _OrderRow({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShopOrderDetailsScreen()),
        );
      },
      child: Container(
        height: 40,
        color: backgroundColor,
        child: Row(
          children: [
            _Cell(text: id, flex: 3),
            _Cell(text: date, flex: 3),
            _Cell(text: time, flex: 3),
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Campton',
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
            fontWeight: isHeader ? FontWeight.w400 : FontWeight.w400,
            color: isHeader
                ? const Color(0xFF777F84)
                : const Color(0xFF000000).withOpacity(0.97),
            fontFamily: 'Campton',
          ),
        ),
      ),
    );
  }
}
