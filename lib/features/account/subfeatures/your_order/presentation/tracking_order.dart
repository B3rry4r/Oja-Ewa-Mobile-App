// tracking_order_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

class TrackingOrderScreen extends StatelessWidget {
  const TrackingOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
              title: Text(
                'Track Order',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
            ),

            // Order ID
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Text(
                '#rt667899hnny007',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: const Color(0xFF3C4042),
                ),
              ),
            ),

            // Main content - Scrollable area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shipping Info Card
                    _buildShippingInfoCard(),

                    // Tracking Timeline - Proper implementation
                    _buildTrackingTimeline(),

                    // Decorative image (low opacity)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.03,
                        child: Image.asset(
                          AppImages.logoOutline,
                          width: 234,
                          height: 347,
                          fit: BoxFit.contain,
                        ),
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

  Widget _buildShippingInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipping company
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

          // Delivery date
          _buildInfoSection(
            label: 'Estimated Delivery Date',
            value: 'March 20 - March 25',
            labelColor: const Color(0xFF777F84),
          ),
          const SizedBox(height: 16),

          // Tracking number with copy button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoSection(
                  label: 'Tracking Number',
                  value: 'NG1234567890',
                  labelColor: const Color(0xFF777F84),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: const Text(
                  'Copy',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    color: Color(0xFF777F84),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String label,
    required String value,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Campton',
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF3C4042),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    const List<TimelineStep> steps = [
      TimelineStep(
        title: 'Delivered',
        timestamp: 'Mar 25 2023  06:30',
        isCompleted: true,
        isCurrent: false,
        dotColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TimelineStep(
        title: 'Out for Delivery',
        timestamp: 'Mar 25 2023  06:30',
        isCompleted: true,
        isCurrent: false,
        dotColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TimelineStep(
        title: 'Shipped',
        timestamp: 'Mar 25 2023  06:30',
        isCompleted: true,
        isCurrent: false,
        dotColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TimelineStep(
        title: 'Processing',
        timestamp: 'Mar 25 2023  06:30',
        isCompleted: true,
        isCurrent: false,
        dotColor: Color(0xFFE9E9E9),
        textColor: Color(0xFFE9E9E9),
        timeColor: Color(0xFFDEDEDE),
      ),
      TimelineStep(
        title: 'Order Placed',
        timestamp: 'Mar 25 2023  06:30',
        isCompleted: true,
        isCurrent: true,
        dotColor: Color(0xFF603814),
        textColor: Colors.black,
        timeColor: Color(0xFF777F84),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildTimelineItem(steps[i]),
            if (i < steps.length - 1) _buildTimelineConnector(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineStep step) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot with proper centering
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: step.dotColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: step.isCurrent
              ? Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  color: step.textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.timestamp,
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
    );
  }

  Widget _buildTimelineConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connector line centered with the dot
          Container(width: 1, height: 26, color: const Color(0xFFD9D9D9)),
          const SizedBox(width: 29), // Space to align with next dot
        ],
      ),
    );
  }
}

class TimelineStep {
  final String title;
  final String timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final Color dotColor;
  final Color textColor;
  final Color timeColor;

  const TimelineStep({
    required this.title,
    required this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    required this.dotColor,
    required this.textColor,
    required this.timeColor,
  });
}
