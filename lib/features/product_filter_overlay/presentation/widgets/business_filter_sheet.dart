import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/features/categories/presentation/controllers/listing_filters_controller.dart';

class BusinessFilterSheet extends ConsumerWidget {
  const BusinessFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
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
                Expanded(
                  child: Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(businessListingFiltersProvider.notifier).clear();
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Clear', style: TextStyle(color: colors.accent)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _field(context, 'State', 'e.g Lagos', stateCtrl),
            const SizedBox(height: 12),
            _field(context, 'City', 'e.g Ikeja', cityCtrl),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                ref
                    .read(businessListingFiltersProvider.notifier)
                    .setStateValue(
                      stateCtrl.text.trim().isEmpty
                          ? null
                          : stateCtrl.text.trim(),
                    );
                ref
                    .read(businessListingFiltersProvider.notifier)
                    .setCity(
                      cityCtrl.text.trim().isEmpty
                          ? null
                          : cityCtrl.text.trim(),
                    );
                Navigator.of(context).pop(true);
              },
              child: Container(
                width: double.infinity,
                height: 57,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: colors.onAccent,
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

  Widget _field(
    BuildContext context,
    String label,
    String hint,
    TextEditingController ctrl,
  ) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: ctrl,
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'Campton',
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
