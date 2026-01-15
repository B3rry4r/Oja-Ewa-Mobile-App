import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';

class SellerApprovalStatusScreen extends ConsumerWidget {
  const SellerApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(mySellerStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: Column(
        children: [
          const AppHeader(
            backgroundColor: Color(0xFFFFF8F1),
            iconColor: Color(0xFF241508),
            showActions: false,
          ),
          Expanded(
            child: statusAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load status: $e')),
              data: (status) {
                if (status == null) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sellerOnboarding),
                      child: const Text('Start Selling'),
                    ),
                  );
                }

                final title = switch (status.registrationStatus) {
                  'approved' => status.active ? 'Seller Approved' : 'Seller Deactivated',
                  'pending' => 'Seller Pending Approval',
                  'rejected' => 'Seller Rejected',
                  _ => 'Seller Status',
                };

                final message = switch (status.registrationStatus) {
                  'approved' => status.active
                      ? 'Your seller profile is approved. You can now access Your Shop.'
                      : 'Your seller profile was deactivated. Please contact support.',
                  'pending' => 'We are reviewing your seller application. This takes 12–24 hours.',
                  'rejected' => 'Your seller application was rejected. Please update and resubmit.',
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF241508),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E2021),
                          height: 1.4,
                        ),
                      ),
                      if ((status.rejectionReason ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Reason: ${status.rejectionReason}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Campton',
                            color: Color(0xFF777F84),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (status.isApprovedAndActive)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.yourShopDashboard,
                              (r) => false,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDAF40),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Go to Your Shop'),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
                            child: const Text('Back Home'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
