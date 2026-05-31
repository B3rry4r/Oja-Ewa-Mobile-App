import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/business_management_controller.dart';

class ManagePaymentScreen extends ConsumerStatefulWidget {
  const ManagePaymentScreen({super.key});

  @override
  ConsumerState<ManagePaymentScreen> createState() =>
      _ManagePaymentScreenState();
}

class _ManagePaymentScreenState extends ConsumerState<ManagePaymentScreen> {
  String _plan = 'basic';
  String _cycle = 'monthly';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'manage payment',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 140), // Spacing to match top: 214 intent
            // Expiration and Status Text
            Text(
              'Your payment will expire on 24th july, 2023\n'
              'Your account will no longer show on the\n'
              'platform if you dont renew',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Plan selection (basic/premium/enterprise)
            DropdownButton<String>(
              value: _plan,
              dropdownColor: colors.surface,
              style: TextStyle(
                color: colors.textPrimary,
              ),
              items: const [
                DropdownMenuItem(value: 'basic', child: Text('Basic')),
                DropdownMenuItem(value: 'premium', child: Text('Premium')),
                DropdownMenuItem(
                  value: 'enterprise',
                  child: Text('Enterprise'),
                ),
              ],
              onChanged: (v) => setState(() => _plan = v ?? 'basic'),
            ),
            const SizedBox(height: 12),
            // Billing cycle selection
            DropdownButton<String>(
              value: _cycle,
              dropdownColor: colors.surface,
              style: TextStyle(
                color: colors.textPrimary,
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _cycle = v ?? 'monthly'),
            ),

            const SizedBox(height: 24),

            // Renew Subscription Button
            GestureDetector(
              onTap: () async {
                final args = ModalRoute.of(context)?.settings.arguments;
                final businessId =
                    (args is Map ? args['businessId'] : null) as int?;
                if (businessId == null) return;

                await ref
                    .read(businessManagementActionsProvider.notifier)
                    .renewSubscription(
                      businessId: businessId,
                      subscriptionType: _plan,
                      billingCycle: _cycle,
                    );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription updated')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Renew Subscription',
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 16,
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
}
