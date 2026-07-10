// seller_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';

import '../../../../../app/router/app_router.dart';

class SellerOnboardingScreen extends ConsumerWidget {
  const SellerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sellerStatusAsync = ref.watch(mySellerStatusProvider);

    // If seller profile exists, redirect to appropriate screen
    return sellerStatusAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _buildOnboardingContent(context),
      data: (status) {
        // If seller status exists (pending, approved, or rejected), redirect
        if (status != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            if (status.isApprovedAndActive) {
              // Use pushReplacementNamed to prevent navigation loop
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.yourShopDashboard);
            } else {
              // Pending or rejected - show approval status screen
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.sellerApprovalStatus);
            }
          });
          // Show loading while redirecting
          return Scaffold(
            backgroundColor: colors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No seller profile yet - show onboarding
        return _buildOnboardingContent(context);
      },
    );
  }

  Widget _buildOnboardingContent(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Text(
            'Sell on WAWUBeauty',
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Tell your Story on WAWUBeauty. Where makers build their legacy. List your work, tell your story, reach the world.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          _buildQualityStandardsBanner(context),

          const SizedBox(height: 32),

          _buildHowItWorksSection(context),

          const SizedBox(height: 40),

          _buildStartSellingButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQualityStandardsBanner(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: colors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Our Quality Promise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'At WAWUBeauty your trust is our foundation. Every product on WAWUBeauty must pass our verification for authenticity and craftsmanship.\n\n'
            'We invest in your success by ensuring only excellence reaches our marketplace.\n\n'
            'Based on who you be, we ensure what you sell is worthy.\n\n'
            'The WAWUBeauty Team',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final colors = context.appColors;
    const List<HowItWorksStep> steps = [
      HowItWorksStep(
        number: '1',
        description: 'Fill in your business Information and Bank Details',
      ),
      HowItWorksStep(
        number: '2',
        description: 'Wait for WAWUBeauty to approve your details',
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
        Text(
          'How it works',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 40),

        // Steps list
        Column(
          children: [
            for (int i = 0; i < steps.length; i++)
              _buildStepItem(context, steps[i]),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem(BuildContext context, HowItWorksStep step) {
    final colors = context.appColors;
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
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step.number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.background,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Step description
          Expanded(
            child: Text(
              step.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSellingButton(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.sellerRegistration);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: Text(
              'Start Selling',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onAccent,
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
