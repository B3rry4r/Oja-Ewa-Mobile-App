// seller_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';

import '../../../../../app/router/app_router.dart';

class SellerOnboardingScreen extends ConsumerWidget {
  const SellerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerStatusAsync = ref.watch(mySellerStatusProvider);

    // If seller profile exists, route based on status
    sellerStatusAsync.whenOrNull(
      data: (status) {
        if (status == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (status.isApprovedAndActive) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.yourShopDashboard,
              (r) => false,
            );
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.sellerApprovalStatus,
              (r) => false,
            );
          }
        });
      },
    );

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

                    const SizedBox(height: 40),

                    // "How it works" section
                    _buildHowItWorksSection(),

                    const SizedBox(height: 40),

                    // Start Selling button
                    _buildStartSellingButton(context),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
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
