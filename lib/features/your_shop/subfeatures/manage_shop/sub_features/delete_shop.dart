import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';

import '../../../../../core/widgets/confirmation_modal.dart';

class DeleteShopScreen extends ConsumerStatefulWidget {
  const DeleteShopScreen({super.key});

  @override
  ConsumerState<DeleteShopScreen> createState() => _DeleteShopScreenState();
}

class _DeleteShopScreenState extends ConsumerState<DeleteShopScreen> {
  bool _isDeleting = false;
  // Local state to track selected reason
  String? selectedReason;

  final List<String> reasons = [
    "Not making money",
    "Switching to another platform",
    "Technical issues",
    "Too expensive",
    "Other",
  ];

  Future<void> _deleteShop() async {
    if (selectedReason == null || _isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      await ref
          .read(sellerStatusApiProvider)
          .deleteSellerProfile(reason: selectedReason);

      // Invalidate the seller status provider to refresh state
      ref.invalidate(mySellerStatusProvider);

      if (mounted) {
        AppSnackbars.showSuccess(context, 'Shop deleted successfully');
        // Navigate back to home
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Failed to delete shop: $e');
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      // Body is a ListView/GridView: it needs a bounded height and scrolls itself.
      scrollable: false,
      title: 'Why are you leaving',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reasons.length,
              itemBuilder: (context, index) {
                return _buildReasonRow(reasons[index]);
              },
            ),
          ),
          _buildDeleteButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReasonRow(String reason) {
    final colors = context.appColors;
    final bool isSelected = selectedReason == reason;

    return GestureDetector(
      onTap: () => setState(() => selectedReason = reason),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Custom Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? colors.accent : colors.textSecondary,
                  width: 2,
                ),
                color: isSelected ? colors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: colors.onAccent)
                  : null,
            ),
            const SizedBox(width: 12),
            // Reason Text
            Text(
              reason,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final colors = context.appColors;
    final isDisabled = selectedReason == null || _isDeleting;

    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              ConfirmationModal.show(
                context,
                title: 'Delete Shop',
                message:
                    'Are you sure you want to delete your shop? This action cannot be undone.',
                confirmLabel: 'Delete',
                onConfirm: _deleteShop,
              );
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: isDisabled
              ? colors.accent.withValues(alpha: 0.5)
              : colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isDeleting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.onAccent),
                  ),
                )
              : Text(
                  "Continue to delete",
                  style: TextStyle(
                    color: colors.onAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
