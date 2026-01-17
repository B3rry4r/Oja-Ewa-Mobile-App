// tracking_order_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/orders/data/orders_repository_impl.dart';

final _orderDetailsForTrackingProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, orderId) async {
  return ref.read(ordersRepositoryProvider).getOrderDetails(orderId);
});

final _orderTrackingProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, orderId) async {
  return ref.read(ordersRepositoryProvider).getOrderTracking(orderId);
});

class TrackingOrderScreen extends ConsumerWidget {
  const TrackingOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = (args is Map && args['orderId'] is int) ? args['orderId'] as int : null;

    if (orderId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8F1),
        body: SafeArea(child: Center(child: Text('Missing order id'))),
      );
    }

    final orderAsync = ref.watch(_orderDetailsForTrackingProvider(orderId));
    final trackingAsync = ref.watch(_orderTrackingProvider(orderId));

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

            // Order ID (UI preserved)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Text(
                '#$orderId',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFF3C4042),
                ),
              ),
            ),

            // Main content - Scrollable area
            Expanded(
              child: trackingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Failed to load tracking: $e')),
                data: (trackingResponse) {
                  final trackingData = trackingResponse['data'] as Map<String, dynamic>? ?? trackingResponse;
                  final estimatedDelivery = trackingData['estimated_delivery'] as String?;
                  final trackingNumber = trackingData['tracking_number'] as String?;

                  final stagesRaw = trackingData['stages'] as List?;
                  final stages = stagesRaw
                          ?.whereType<Map>()
                          .map((m) => Map<String, dynamic>.from(m))
                          .map(_TrackingStage.fromJson)
                          .toList() ??
                      [];

                  final steps = _mapStagesToTimelineSteps(stages, fallbackStatus: trackingData['status'] as String?);

                  final firstProductName = orderAsync.asData?.value.isNotEmpty == true
                      ? _firstProductName(orderAsync.asData!.value)
                      : 'Order Item';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shipping Info Card (UI preserved; top label now product name)
                        _buildShippingInfoCard(
                          context: context,
                          productName: firstProductName,
                          estimatedDelivery: estimatedDelivery,
                          trackingNumber: trackingNumber,
                        ),

                        // Tracking Timeline (UI preserved; now data-driven)
                        _buildTrackingTimeline(steps),

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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstProductName(Map<String, dynamic> orderDetails) {
    final items = orderDetails['order_items'];
    if (items is List && items.isNotEmpty) {
      final first = items.first;
      if (first is Map) {
        final product = first['product'];
        if (product is Map && product['name'] is String) {
          return product['name'] as String;
        }
      }
    }
    return 'Order Item';
  }

  Widget _buildShippingInfoCard({
    required BuildContext context,
    required String productName,
    required String? estimatedDelivery,
    required String? trackingNumber,
  }) {
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
          Text(
            productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 20),

          _buildInfoSection(
            label: 'Estimated Delivery Date',
            value: estimatedDelivery ?? '—',
            labelColor: const Color(0xFF777F84),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoSection(
                  label: 'Tracking Number',
                  value: trackingNumber ?? '—',
                  labelColor: const Color(0xFF777F84),
                ),
              ),
              const SizedBox(width: 8),
              if (trackingNumber != null && trackingNumber.isNotEmpty)
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: trackingNumber));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied')),
                      );
                    }
                  },
                  child: Container(
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

  Widget _buildTrackingTimeline(List<TimelineStep> steps) {
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
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: step.dotColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: step.isCurrent
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
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
              if (step.isCompleted) ...[
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
          Container(width: 1, height: 26, color: const Color(0xFFD9D9D9)),
          const SizedBox(width: 29),
        ],
      ),
    );
  }

  List<TimelineStep> _mapStagesToTimelineSteps(
    List<_TrackingStage> stages, {
    String? fallbackStatus,
  }) {
    if (stages.isEmpty) {
      return _defaultTimeline(fallbackStatus);
    }

    // The backend uses `status`, `timestamp`, `completed`.
    final normalized = stages.map((s) {
      final isActive = s.completed;
      final timestampRaw = s.date ?? s.description ?? '';
      final timestamp = (timestampRaw.trim().isEmpty || timestampRaw.trim() == '_') ? '—' : timestampRaw;
      return TimelineStep(
        title: s.title,
        timestamp: timestamp,
        isCompleted: isActive,
        isCurrent: isActive,
        dotColor: isActive ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
        textColor: isActive ? const Color(0xFF241508) : const Color(0xFFBEBEBE),
        timeColor: isActive ? const Color(0xFF777F84) : const Color(0xFFDEDEDE),
      );
    }).toList();

    // Ensure proper order (Order Placed -> Processing -> Shipped -> Delivered)
    final ordered = _orderTimeline(normalized);
    return ordered;
  }

  List<TimelineStep> _orderTimeline(List<TimelineStep> steps) {
    const order = ['Order Placed', 'Processing', 'Shipped', 'Delivered'];
    final sorted = <TimelineStep>[];
    for (final label in order) {
      final match = steps.where((s) => s.title.toLowerCase().contains(label.toLowerCase())).toList();
      if (match.isNotEmpty) {
        sorted.add(match.first);
      }
    }
    // Add any unknown steps at end
    for (final s in steps) {
      if (!sorted.contains(s)) sorted.add(s);
    }
    return sorted;
  }

  List<TimelineStep> _defaultTimeline(String? status) {
    final normalized = (status ?? 'pending').toLowerCase();

    if (normalized == 'cancelled' || normalized == 'canceled') {
      return [
        _timelineStep('Order Placed', true, isCurrent: false),
        _timelineStep('Cancelled', true, isCurrent: true),
      ];
    }

    final Map<String, bool> completed = {
      'order placed': true,
      'processing': normalized == 'processing' || normalized == 'shipped' || normalized == 'delivered',
      'shipped': normalized == 'shipped' || normalized == 'delivered',
      'delivered': normalized == 'delivered',
    };

    final steps = [
      _timelineStep('Order Placed', completed['order placed']!, isCurrent: normalized == 'pending'),
      _timelineStep('Processing', completed['processing']!, isCurrent: normalized == 'processing'),
      _timelineStep('Shipped', completed['shipped']!, isCurrent: normalized == 'shipped'),
      _timelineStep('Delivered', completed['delivered']!, isCurrent: normalized == 'delivered'),
    ];

    return steps;
  }

  TimelineStep _timelineStep(String title, bool isCompleted, {bool isCurrent = false}) {
    return TimelineStep(
      title: title,
      timestamp: isCompleted ? 'Completed' : '—',
      isCompleted: isCompleted,
      isCurrent: isCurrent,
      dotColor: isCompleted ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
      textColor: isCompleted ? const Color(0xFF241508) : const Color(0xFFBEBEBE),
      timeColor: isCompleted ? const Color(0xFF777F84) : const Color(0xFFDEDEDE),
    );
  }
}

class _TrackingStage {
  final String title;
  final String? description;
  final bool completed;
  final String? date;

  const _TrackingStage({
    required this.title,
    required this.description,
    required this.completed,
    required this.date,
  });

  factory _TrackingStage.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?) ?? (json['status'] as String?) ?? '';
    final date = (json['date'] as String?) ?? (json['timestamp'] as String?) ?? (json['updated_at'] as String?);
    return _TrackingStage(
      title: title.isEmpty ? 'Order Placed' : title,
      description: json['description'] as String?,
      completed: (json['completed'] as bool?) ?? false,
      date: date,
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
