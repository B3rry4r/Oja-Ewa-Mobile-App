import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/business_management_controller.dart';

class ManagePaymentScreen extends ConsumerStatefulWidget {
  const ManagePaymentScreen({super.key});

  @override
  ConsumerState<ManagePaymentScreen> createState() => _ManagePaymentScreenState();
}

class _ManagePaymentScreenState extends ConsumerState<ManagePaymentScreen> {
  String _plan = 'basic';
  String _cycle = 'monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Cream background from IR
      body: Column(
        children: [
          const AppHeader(
            backgroundColor: Color(0xFFFFF8F1),
            iconColor: Color(0xFF241508),
            title: Text(
              'manage payment',
              style: TextStyle(
                color: Color(0xFF241508),
                fontSize: 22,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 140), // Spacing to match top: 214 intent

                  // Expiration and Status Text
                  const Text(
                    'Your payment will expire on 24th july, 2023\n'
                    'Your account will no longer show on the\n'
                    'platform if you dont renew',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF3C4042),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Plan selection (basic/premium/enterprise)
                  DropdownButton<String>(
                    value: _plan,
                    items: const [
                      DropdownMenuItem(value: 'basic', child: Text('Basic')),
                      DropdownMenuItem(value: 'premium', child: Text('Premium')),
                      DropdownMenuItem(value: 'enterprise', child: Text('Enterprise')),
                    ],
                    onChanged: (v) => setState(() => _plan = v ?? 'basic'),
                  ),
                  const SizedBox(height: 12),
                  // Billing cycle selection
                  DropdownButton<String>(
                    value: _cycle,
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
                      final businessId = (args is Map ? args['businessId'] : null) as int?;
                      if (businessId == null) return;

                      await ref.read(businessManagementActionsProvider.notifier).renewSubscription(
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
                        color: const Color(0xFFFDAF40),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFDAF40).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Renew Subscription',
                          style: TextStyle(
                            color: Color(0xFFFFFBF5),
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
          ),
        ],
      ),
    );
  }
}
