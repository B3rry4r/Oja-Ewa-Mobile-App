import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';

class BusinessApprovalStatusScreen extends ConsumerWidget {
  const BusinessApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(myBusinessStatusesProvider);

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
            child: businessesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load status: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.businessOnboarding),
                      child: const Text('Create Business Profile'),
                    ),
                  );
                }

                // Choose most recent-ish by id
                final b = items.reduce((a, c) => c.id > a.id ? c : a);

                final title = switch (b.storeStatus) {
                  'approved' => 'Business Approved',
                  'pending' => 'Business Pending Approval',
                  'deactivated' => 'Business Deactivated',
                  _ => 'Business Status',
                };

                final message = switch (b.storeStatus) {
                  'approved' => 'Your business profile is approved. You can manage it now.',
                  'pending' => 'We are reviewing your business profile. This takes 12–24 hours.',
                  'deactivated' => 'Your business profile was deactivated. Please update and resubmit.',
                  _ => 'Status: ${b.storeStatus}',
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
                      if ((b.rejectionReason ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Reason: ${b.rejectionReason}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Campton',
                            color: Color(0xFF777F84),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (b.storeStatus == 'approved')
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.businessSettings,
                              (r) => false,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDAF40),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Manage Business'),
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
