import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/subscriptions/subscription_controller.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';

import '../../../../../app/router/app_router.dart';

class BusinessOnboardingScreen extends ConsumerWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(myBusinessStatusesProvider);
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);
    final subscription = subscriptionAsync.value?.subscription;
    final hasPro = subscription != null && subscription.status.isActive;

    businessesAsync.whenOrNull(
      data: (items) {
        if (items.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final hasApproved = items.any((b) => b.storeStatus == 'approved');
          if (hasApproved) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.businessSettings, (r) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.businessApprovalStatus,
              (r) => false,
            );
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(
                backgroundColor: Color(0xFFFFF8F1),
                iconColor: Color(0xFF241508),
                title: Text(
                  'Show',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF241508),
                    fontFamily: 'Campton',
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Hero Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Share your Business Heritage on Ojá-Ẹwà",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Craftsmanship, agency, and the tangible connection between cultural identity and creative expression.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1E2021),
                        fontFamily: 'Campton',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // How It Works Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5E0CE), // Section background
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How it works",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStepRow("1", "Provide your business information"),
                    _buildStepRow(
                      "2",
                      "Wait for Ojá-Ẹwà to approve your details",
                    ),
                    _buildStepRow(
                      "3",
                      "Wait and let people looking for your products or services find you",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Secondary CTA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: hasPro
                    ? _buildPrimaryButton(context, "Get Started")
                    : _buildSubscriptionGate(context, ref),
              ),
              const SizedBox(height: 100), // Space for BottomNav
            ],
          ),
        ),
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
            'Subscribe to Ojaewa Pro to publish your business profile and sell on the platform. AI tools are included.',
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

  Widget _buildPrimaryButton(BuildContext context, String text) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.businessCategory),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFFFFBF5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF603814), // Step icon color
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFFFFF8F1),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E2021),
                fontFamily: 'Campton',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
