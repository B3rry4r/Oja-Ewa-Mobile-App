import 'package:flutter/material.dart';

class YourShopDashboard extends StatelessWidget {
  const YourShopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #fff8f1
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Shop info section
              _buildShopInfo(),
              const SizedBox(height: 24),
              
              // Stats cards
              _buildStatsSection(),
              const SizedBox(height: 24),
              
              // Search section
              _buildSearchSection(),
              const SizedBox(height: 24),
              
              // Orders section
              _buildOrdersSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black54,
            ),
          ),
          
          // Title
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your Shop',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508), // #241508
                  letterSpacing: -1,
                  height: 1.2,
                ),
              ),
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined),
              const SizedBox(width: 8),
              _buildIconButton(Icons.more_vert),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 20,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildShopInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dijee Stitches',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2021), // #1e2021
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Manage Shop',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF301C0A), // #301c0a
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Products',
              count: '20',
              color: const Color(0xFFF5E0CE), // #f5e0ce
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              title: 'Orders',
              count: '100',
              color: const Color(0xFFF5E0CE), // #f5e0ce
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Campton',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF777F84), // #777f84
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Campton',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508), // #241508
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'View',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1E2021), // #1e2021
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: const Color(0xFF1E2021).withOpacity(0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 24,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'search Oja Ewa',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFCCCCCC), // #cccccc
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1), // #fff8f1
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
            child: Text(
              'Orders in Process',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E2021), // #1e2021
                height: 1.2,
              ),
            ),
          ),
          
          // Table header
          _buildTableHeader(),
          
          // Table rows
          _buildOrderRow(
            orderNumber: '#hg5675894h',
            orderDate: 'Jan 6 2023',
            package: 'Quick Quick',
            status: 'In Process',
            backgroundColor: const Color(0xFFFBFBFB), // #fbfbfb
          ),
          _buildOrderRow(
            orderNumber: '#hg5675894h',
            orderDate: 'Jan 6 2023',
            package: 'Quick Quick',
            status: 'In Process',
            backgroundColor: const Color(0xFFF4F4F4), // #f4f4f4
          ),
          _buildOrderRow(
            orderNumber: '#hg5675894h',
            orderDate: 'Jan 6 2023',
            package: 'Quick Quick',
            status: 'In Process',
            backgroundColor: const Color(0xFFFBFBFB), // #fbfbfb
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E0CE), // #f5e0ce
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'Order No',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF777F84), // #777f84
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              'Order Date',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF777F84), // #777f84
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 71,
            child: Text(
              'Package',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF777F84), // #777f84
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 53,
            child: Text(
              'Status',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF777F84), // #777f84
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow({
    required String orderNumber,
    required String orderDate,
    required String package,
    required String status,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              orderNumber,
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              orderDate,
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(
            width: 71,
            child: Text(
              package,
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ),
          _buildStatusTag(status),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3095CE), // #3095ce
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontFamily: 'Campton',
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFBFBFB), // #fbfbfb
          height: 1.2,
        ),
      ),
    );
  }
}