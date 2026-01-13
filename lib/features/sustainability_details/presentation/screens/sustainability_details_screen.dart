import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/sustainability_details_controller.dart';

class SustainabilityDetailsScreen extends ConsumerWidget {
  const SustainabilityDetailsScreen({super.key, required this.initiativeId});

  final int initiativeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sustainabilityDetailsProvider(initiativeId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF603814),
        foregroundColor: Colors.white,
        title: const Text('Initiative'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load initiative')),
        data: (d) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if ((d.description ?? '').trim().isNotEmpty) Text(d.description!),
              const SizedBox(height: 16),
              if (d.progressPercentage != null)
                Text('Progress: ${d.progressPercentage}%'),
            ],
          ),
        ),
      ),
    );
  }
}
