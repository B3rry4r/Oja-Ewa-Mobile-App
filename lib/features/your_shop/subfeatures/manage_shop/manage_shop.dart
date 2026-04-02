import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

import '../../../../../app/router/app_router.dart';

class ManageShopScreen extends StatelessWidget {
  const ManageShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'Manage Shop',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuOption(
            context: context,
            title: "Edit Business Information",
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.editBusiness),
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
      height: 72, // Height from IR
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
                fontFamily: 'Campton',
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
