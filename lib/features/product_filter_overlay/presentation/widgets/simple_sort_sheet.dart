import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/features/categories/presentation/controllers/listing_filters_controller.dart';

class SimpleSortSheet extends ConsumerWidget {
  const SimpleSortSheet({super.key, required this.isBusiness});

  final bool isBusiness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = isBusiness
        ? ref.watch(businessListingFiltersProvider).sort
        : ref.watch(sustainabilityListingFiltersProvider).sort;

    final options = <({String label, String value})>[
      (label: 'Newest', value: 'newest'),
      (label: 'Oldest', value: 'oldest'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2021),
              ),
            ),
            const SizedBox(height: 16),
            for (final opt in options)
              ListTile(
                title: Text(opt.label, style: const TextStyle(fontFamily: 'Campton')),
                trailing: selected == opt.value
                    ? const Icon(Icons.radio_button_checked, color: Color(0xFFFDAF40))
                    : const Icon(Icons.radio_button_off, color: Color(0xFFCCCCCC)),
                onTap: () {
                  if (isBusiness) {
                    ref.read(businessListingFiltersProvider.notifier).setSort(opt.value);
                  } else {
                    ref.read(sustainabilityListingFiltersProvider.notifier).setSort(opt.value);
                  }
                  Navigator.of(context).pop(true);
                },
              ),
          ],
        ),
      ),
    );
  }
}
