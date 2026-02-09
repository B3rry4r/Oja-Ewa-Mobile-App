// seller_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/subscriptions/subscription_controller.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';

import '../../../../../app/router/app_router.dart';

class SellerOnboardingScreen extends ConsumerWidget {
  const SellerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerStatusAsync = ref.watch(mySellerStatusProvider);
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);
    final subscription = subscriptionAsync.value?.subscription;
    final hasPro = subscription != null && subscription.status.isActive;

    // If seller profile exists, redirect to appropriate screen
    return sellerStatusAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFFF8F1),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildOnboardingContent(context, ref, hasPro),
      data: (status) {
        // If seller status exists (pending, approved, or rejected), redirect
        if (status != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            if (status.isApprovedAndActive) {
              // Use pushReplacementNamed to prevent navigation loop
              Navigator.of(context).pushReplacementNamed(AppRoutes.yourShopDashboard);
            } else {
              // Pending or rejected - show approval status screen
              Navigator.of(context).pushReplacementNamed(AppRoutes.sellerApprovalStatus);
            }
          });
          // Show loading while redirecting
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F1),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // No seller profile yet - show onboarding
        return _buildOnboardingContent(context, ref, hasPro);
      },
    );
  }

  Widget _buildOnboardingContent(BuildContext context, WidgetRef ref, bool hasPro) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Main title
                    const Text(
                      'Sell on Ojá-Ẹwà',
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Campton',
                        color: Color(0xFF241508),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    const Text(
                      'Tell your Story on Ojá-Ẹwà. Where makers build their legacy. List your work, tell your story, reach the world.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1E2021),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quality Standards Banner
                    _buildQualityStandardsBanner(),

                    const SizedBox(height: 32),

                    // "How it works" section
                    _buildHowItWorksSection(),

                    const SizedBox(height: 40),

                    if (hasPro) ...[
                      // Start Selling button
                      _buildStartSellingButton(context),
                      const SizedBox(height: 40),
                    ] else ...[
                      _buildSubscriptionGate(context, ref),
                      const SizedBox(height: 24),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityStandardsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAF40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Color(0xFFFDAF40),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Our Quality Promise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: Color(0xFF241508),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'At Ojá-Ẹwà your trust is our foundation. Every product on Ojá-Ẹwà must pass our verification for authenticity and craftsmanship.\n\n'
            'We guarantee: If a newly registered brand/product fails our review and does not meet our published Quality Standards, its registration fee will be fully refunded.\n\n'
            'We invest in your success by ensuring only excellence reaches our marketplace.\n\n'
            'Based on who you be, we ensure what you sell is worthy.\n\n'
            'The Ojá-Ẹwà Team',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionGate(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final isLoading = subscriptionState.value?.isLoading ?? false;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E0CE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ojaewa Pro Required',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Subscribe to Ojaewa Pro to sell on the platform and publish your seller profile. AI tools are included.',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: Color(0xFF777F84),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.termsOfService),
                  child: const Text(
                    'View Terms of Service',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFDAF40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  await ref.read(iapServiceProvider).purchaseSubscription(
                        SubscriptionProducts.ojaewaProYearly,
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDAF40),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                ),
                child: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Subscribe'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    const List<HowItWorksStep> steps = [
      HowItWorksStep(
        number: '1',
        description: 'Fill in your business Information and Bank Details',
      ),
      HowItWorksStep(
        number: '2',
        description: 'Wait for Ojá-Ẹwà to approve your details',
      ),
      HowItWorksStep(
        number: '3',
        description: 'Start Uploading your designs on the market',
      ),
      HowItWorksStep(
        number: '4',
        description: 'Customers find products they love and purchase',
      ),
      HowItWorksStep(
        number: '5',
        description: 'You get paid when you deliver your orders',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "How it works" title
        const Text(
          'How it works',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: Color(0xFF241508),
          ),
        ),

        const SizedBox(height: 16),

        // Step note
        const Text(
          '*Selling is strictly for fashion designers',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2021),
          ),
        ),

        const SizedBox(height: 40),

        // Steps list
        Column(
          children: [
            for (int i = 0; i < steps.length; i++) _buildStepItem(steps[i]),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem(HowItWorksStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF603814),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                step.number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Campton',
                  color: Color(0xFFFFF8F1),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Step description
          Expanded(
            child: Text(
              step.description,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E2021),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSellingButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.sellerRegistration);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: const Text(
              'Start Selling',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HowItWorksStep {
  final String number;
  final String description;

  const HowItWorksStep({required this.number, required this.description});
}
