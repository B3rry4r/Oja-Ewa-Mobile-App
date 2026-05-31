import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/draft_utils.dart';

import '../../../../../app/router/app_router.dart';

class ManageShopScreen extends ConsumerWidget {
  const ManageShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sellerStatus = ref.watch(sellerStatusProvider);

    return AppPageScaffold(
      title: 'Manage Shop',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuOption(
            context: context,
            title: "Edit Business Information",
            onTap: () {
              // Pre-fill the seller registration form with existing profile data
              // so the seller sees their current info and can update it.
              final args = sellerStatus != null
                  ? sellerDraftFromStatus(sellerStatus).toJson()
                  : <String, dynamic>{};
              Navigator.of(context).pushNamed(
                AppRoutes.sellerRegistration,
                arguments: args,
              );
            },
          ),
          _buildMenuOption(
            context: context,
            title: "Delete Shop",
            titleColor: const Color(0xFFC95353),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.deleteShop),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).extension<AppThemeColors>()!.border,
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor ?? colors.textPrimary,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
