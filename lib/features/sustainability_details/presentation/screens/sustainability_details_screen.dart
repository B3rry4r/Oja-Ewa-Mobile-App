import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import '../controllers/sustainability_details_controller.dart';

class SustainabilityDetailsScreen extends ConsumerWidget {
  const SustainabilityDetailsScreen({super.key, required this.initiativeId});

  final int initiativeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sustainabilityDetailsProvider(initiativeId));
    final colors = context.appColors;

    return AppPageScaffold(
      title: 'Initiative',
      showActions: false,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load initiative')),
        data: (d) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
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
