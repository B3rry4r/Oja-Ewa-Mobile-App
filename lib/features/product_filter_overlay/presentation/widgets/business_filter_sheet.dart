import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/features/categories/presentation/controllers/listing_filters_controller.dart';

class BusinessFilterSheet extends ConsumerWidget {
  const BusinessFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(businessListingFiltersProvider);

    final stateCtrl = TextEditingController(text: f.state ?? '');
    final cityCtrl = TextEditingController(text: f.city ?? '');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(businessListingFiltersProvider.notifier).clear();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Clear', style: TextStyle(color: Color(0xFFFDAF40))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _field('State', 'e.g Lagos', stateCtrl),
            const SizedBox(height: 12),
            _field('City', 'e.g Ikeja', cityCtrl),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                ref.read(businessListingFiltersProvider.notifier).setStateValue(stateCtrl.text.trim().isEmpty ? null : stateCtrl.text.trim());
                ref.read(businessListingFiltersProvider.notifier).setCity(cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim());
                Navigator.of(context).pop(true);
              },
              child: Container(
                width: double.infinity,
                height: 57,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAF40),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: Color(0xFFFFFBF5),
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
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

  Widget _field(String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontFamily: 'Campton', color: Color(0xFF777F84))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
