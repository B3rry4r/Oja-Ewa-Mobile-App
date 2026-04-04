import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/draft_utils.dart';

class SellerApprovalStatusScreen extends ConsumerWidget {
  const SellerApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final statusAsync = ref.watch(mySellerStatusProvider);

    return AppPageScaffold(
      showActions: false,
      child: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load status: $e')),
        data: (status) {
          if (status == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.sellerOnboarding),
                child: const Text('Start Selling'),
              ),
            );
          }

          final title = switch (status.registrationStatus) {
            'approved' =>
              status.active ? 'Seller Approved' : 'Seller Deactivated',
            'pending' => 'Seller Pending Approval',
            'rejected' => 'Seller Rejected',
            _ => 'Seller Status',
          };

          final message = switch (status.registrationStatus) {
            'approved' =>
              status.active
                  ? 'Your seller profile is approved. You can now access Your Shop.'
                  : 'Your seller profile was deactivated. Please contact support.',
            'pending' =>
              'We are reviewing your seller application. This takes 12–24 hours.',
            'rejected' =>
              'Your seller application was rejected. Please update and resubmit.',
            _ => 'Status: ${status.registrationStatus}',
          };

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if ((status.rejectionReason ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reason: ${status.rejectionReason}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      color: colors.textTertiary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (status.isApprovedAndActive)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.yourShopDashboard,
                            (r) => false,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.onAccent,
                      ),
                      child: const Text('Go to Your Shop'),
                    ),
                  )
                else if (status.isRejected)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.sellerRegistration,
                        arguments: sellerDraftFromStatus(status).toJson(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.onAccent,
                      ),
                      child: const Text('Edit and Resubmit'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
                      child: const Text('Back Home'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
