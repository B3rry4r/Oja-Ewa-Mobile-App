// tracking_order_screen.dart
import 'package:flutter/material.dart';

class TrackingOrderScreen extends StatelessWidget {
  const TrackingOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),
              const SizedBox(height: 16),

              // Main Content Card
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button
          Align(
            alignment: Alignment.centerLeft,
            child: _buildIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () {},
            ),
          ),

          // Title
          const Text(
            'Track Order',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
          ),

          // Close/Other Button
          Align(
            alignment: Alignment.centerRight,
            child: _buildIconButton(
              icon: Icons.close_rounded,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              '#rt667899hnny007',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: const Color(0xFF3C4042).withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Shipping Info Card
          _buildShippingInfoCard(),
          const SizedBox(height: 24),

          // Tracking Timeline with correct positioning
          _buildTrackingTimeline(),

          // Decorative Background Element (behind timeline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/tracking_decoration.png',
                width: 234,
                height: 347,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipping Company
          const Text(
            'Zikka Express',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 20),

          // Delivery Date
          _buildInfoRow(
            label: 'Estimated Delivery Date',
            value: 'March 20 - March 25',
          ),
          const SizedBox(height: 16),

          // Tracking Number with Copy Button
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  label: 'Tracking Number',
                  value: 'NG1234567890',
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: const Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      color: Color(0xFF777F84),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: const Color(0xFF3C4042),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    const List<TrackingStep> steps = [
      TrackingStep(
        status: 'Delivered',
        time: 'Mar 25 2023  06:30',
        isActive: false,
        icon: Icons.check_circle_rounded,
        iconColor: Color(0xFFE9E9E9),
        stepColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TrackingStep(
        status: 'Out for Delivery',
        time: 'Mar 25 2023  06:30',
        isActive: false,
        icon: Icons.local_shipping_rounded,
        iconColor: Color(0xFFE9E9E9),
        stepColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TrackingStep(
        status: 'Shipped',
        time: 'Mar 25 2023  06:30',
        isActive: false,
        icon: Icons.inventory_rounded,
        iconColor: Color(0xFFE9E9E9),
        stepColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TrackingStep(
        status: 'Processing',
        time: 'Mar 25 2023  06:30',
        isActive: false,
        icon: Icons.settings_rounded,
        iconColor: Color(0xFFE9E9E9),
        stepColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TrackingStep(
        status: 'Order Placed',
        time: 'Mar 25 2023  06:30',
        isActive: true,
        icon: Icons.shopping_bag_rounded,
        iconColor: Color(0xFF603814),
        stepColor: Color(0xFF603814),
        textColor: Colors.black,
        timeColor: Color(0xFF777F84),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Vertical connector lines positioned ABSOLUTELY
          ..._buildConnectorLines(steps.length),

          // Steps content
          Column(
            children: [
              for (int i = 0; i < steps.length; i++)
                _buildTimelineStep(steps[i], i == steps.length - 1),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConnectorLines(int stepCount) {
    List<Widget> connectors = [];

    // Each connector line is positioned absolutely based on the IR coordinates
    // From the IR: Each connector is 1px wide, 26px tall, positioned at left: 26 (center of 20px icon + 16px left padding)
    for (int i = 0; i < stepCount - 1; i++) {
      // Calculate top position for each connector
      // First step starts at top: 191, connector at top: 214 (after 23px)
      // Each step is approximately 53px apart
      double topPosition = 191 + 53 * i + 23;

      connectors.add(
        Positioned(
          left: 26, // Center of 20px icon (16 + 10)
          top: topPosition,
          child: Container(
            width: 1,
            height: 26,
            color: const Color(0xFFD9D9D9),
          ),
        ),
      );
    }

    return connectors;
  }

  Widget _buildTimelineStep(TrackingStep step, bool isLast) {
    // Calculate vertical positions based on IR data
    // Each step has approximately 53px vertical spacing
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon Container
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: step.stepColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              step.icon,
              size: 16,
              color: step.isActive ? Colors.white : step.iconColor,
            ),
          ),
          const SizedBox(width: 12),

          // Status and Time Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.status,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    color: step.textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.time,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    color: step.timeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: const Color(0xFF241508)),
        onPressed: onPressed,
        padding: const EdgeInsets.all(10),
      ),
    );
  }
}

class TrackingStep {
  final String status;
  final String time;
  final bool isActive;
  final IconData icon;
  final Color iconColor;
  final Color stepColor;
  final Color textColor;
  final Color timeColor;

  const TrackingStep({
    required this.status,
    required this.time,
    required this.isActive,
    required this.icon,
    required this.iconColor,
    required this.stepColor,
    required this.textColor,
    required this.timeColor,
  });
}
