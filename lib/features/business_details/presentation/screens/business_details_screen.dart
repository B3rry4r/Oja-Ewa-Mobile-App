import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/business_details_controller.dart';

/// Minimal business details screen that can be used by category listings.
///
/// UI is intentionally simple to avoid redesigning existing category-specific
/// detail screens. We can later map fields into the dedicated Beauty/Music/etc
/// detail UIs as needed.
class BusinessDetailsScreen extends ConsumerWidget {
  const BusinessDetailsScreen({super.key, required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(businessDetailsProvider(businessId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF603814),
        foregroundColor: Colors.white,
        title: const Text('Business'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load business')),
        data: (b) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.businessName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if ((b.businessDescription ?? '').trim().isNotEmpty) Text(b.businessDescription!),
              const SizedBox(height: 16),
              if (b.serviceList.isNotEmpty) ...[
                const Text('Services', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: b.serviceList.map((s) => Chip(label: Text(s))).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
