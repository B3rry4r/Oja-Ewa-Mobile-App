// onboarding_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using Material scaffold for proper safe area handling
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #fff8f1
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(),
              
              // Content Section with proper spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Spacing from image to title
                    
                    // Main Headline
                    _buildHeadline(),
                    
                    const SizedBox(height: 90), // Spacing from title to buttons
                    
                    // Action Buttons
                    _buildActionButtons(context),
                    
                    const SizedBox(height: 32), // Bottom spacing
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Hero Image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: Image.asset(
            AppImages.onboarding,
            width: 375,
            height: 499,
            fit: BoxFit.cover,
          ),
        ),
        
        // Page Indicator Dots
        Positioned(
          top: 500, // Aligns with the bottom of the image
          child: _buildPageIndicator(),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFFDAF40),
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Inactive dot (with border)
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFFDAF40),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Inactive dot (with border)
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFFDAF40),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Text(
      'Bringing out \nyour inner \nradiance',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        fontFamily: 'Campton',
        color: const Color(0xFF1E2021), // #1e2021
        height: 1.1, // Better line height for readability
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
                color: const Color(0xFFFDAF40).withOpacity(0.3),
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
}