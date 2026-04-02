import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/features/categories/presentation/controllers/listing_filters_controller.dart';

class SimpleSortSheet extends ConsumerWidget {
  const SimpleSortSheet({super.key, required this.isBusiness});

  final bool isBusiness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final selected = isBusiness
        ? ref.watch(businessListingFiltersProvider).sort
        : ref.watch(sustainabilityListingFiltersProvider).sort;

    final options = <({String label, String value})>[
      (label: 'Newest', value: 'newest'),
      (label: 'Oldest', value: 'oldest'),
    ];

    return SafeArea(
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            for (final opt in options)
              ListTile(
                title: Text(
                  opt.label,
                  style: TextStyle(
                    fontFamily: 'Campton',
                    color: colors.textPrimary,
                  ),
                ),
                trailing: selected == opt.value
                    ? Icon(Icons.radio_button_checked, color: colors.accent)
                    : Icon(Icons.radio_button_off, color: colors.borderStrong),
                onTap: () {
                  if (isBusiness) {
                    ref
                        .read(businessListingFiltersProvider.notifier)
                        .setSort(opt.value);
                  } else {
                    ref
                        .read(sustainabilityListingFiltersProvider.notifier)
                        .setSort(opt.value);
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
