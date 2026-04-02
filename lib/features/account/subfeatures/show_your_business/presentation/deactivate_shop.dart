import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../core/widgets/confirmation_modal.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/business_management_controller.dart';

class DeactivateShopScreen extends ConsumerWidget {
  const DeactivateShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final args = ModalRoute.of(context)?.settings.arguments;
    final businessId = (args is Map ? args['businessId'] : null) as int?;

    return AppPageScaffold(
      title: 'Deactivate shop',
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Deactivate your shop',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will hide your business from customers until you reactivate it.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                ConfirmationModal.show(
                  context,
                  title: 'Deactivate shop',
                  message: 'Are you sure you want to deactivate your shop?',
                  confirmLabel: 'Deactivate',
                  onConfirm: () async {
                    if (businessId == null) {
                      Navigator.of(context).pop();
                      return;
                    }
                    await ref
                        .read(businessManagementActionsProvider.notifier)
                        .deactivate(businessId);
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                  },
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 57,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Deactivate',
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
