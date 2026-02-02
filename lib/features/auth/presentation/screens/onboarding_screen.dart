// onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            // Hero image - expands to fill available space
            Expanded(
              child: _buildHeroSection(),
            ),
            // Bottom content - fixed at bottom, no scrolling
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeadline(),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                  const SizedBox(height: 16),
                  _buildTermsAndPrivacy(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Hero Image - expands to fill available space
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: Image.asset(
            AppImages.onboarding,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Page Indicator Dots
        // Positioned(
        //   top: 500, // Aligns with the bottom of the image
        //   child: _buildPageIndicator(),
        // ),
      ],
    );
  }

  // Widget _buildPageIndicator() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       // Active dot
  //       Container(
  //         width: 12,
  //         height: 12,
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFFDAF40),
  //           borderRadius: BorderRadius.circular(17),
  //         ),
  //       ),

  //       const SizedBox(width: 20),

  //       // Inactive dot (with border)
  //       Container(
  //         width: 12,
  //         height: 12,
  //         decoration: BoxDecoration(
  //           border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
  //           borderRadius: BorderRadius.circular(17),
  //         ),
  //       ),

  //       const SizedBox(width: 20),

  //       // Inactive dot (with border)
  //       Container(
  //         width: 12,
  //         height: 12,
  //         decoration: BoxDecoration(
  //           border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
  //           borderRadius: BorderRadius.circular(17),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildHeadline() {
    return const Text(
      'The Pan-African\nBeauty Market',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Campton',
        color: Color(0xFF1E2021),
        height: 1.2,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary CTA Button
        Container(
          width: double.infinity,
          height: 57,
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
                Navigator.of(context).pushNamed(AppRoutes.createAccount);
              },
              child: const Center(
                child: Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: Color(0xFFFFFBF5), // #fffbf5
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary Buttons Row
        Row(
          children: [
            // Sign In Button
            Expanded(
              child: Container(
                height: 57,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFDAF40),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.signIn);
                    },
                    child: const Center(
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Campton',
                          color: Color(0xFFFDAF40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Continue as Guest Button
            Expanded(
              child: Container(
                height: 57,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFDAF40),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    child: const Center(
                      child: Text(
                        'Continue as guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Campton',
                          color: Color(0xFFFDAF40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
            height: 1.4,
          ),
          children: [
            const TextSpan(text: "By continuing you agree to ojà-ewà's\n"),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(
                color: Color(0xFFFDAF40),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushNamed(AppRoutes.termsOfService);
                },
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: Color(0xFFFDAF40),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
                },
            ),
          ],
        ),
      ),
    );
  }
}
