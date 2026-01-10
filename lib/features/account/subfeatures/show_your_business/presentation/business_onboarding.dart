import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';

class BusinessOnboardingScreen extends StatelessWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      "Expand your business reach on Oja Ewa",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF241508),
                        fontFamily: 'Campton',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Show your business on Oja Ewa and let more buyers find you",
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
                      "Wait for Oja Ewa to approve your details",
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
                child: _buildPrimaryButton(context, "Get Started"),
              ),
              const SizedBox(height: 100), // Space for BottomNav
            ],
          ),
        ),
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
              color: const Color(0xFFFDAF40).withOpacity(0.4),
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
