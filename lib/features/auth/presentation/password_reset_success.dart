// password_reset_success_screen.dart
import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #fff8f1
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative element
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  width: 234,
                  height: 347,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDAF40).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(150),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 120,
                      color: Color(0xFFFDAF40),
                    ),
                  ),
                ),
              ),
            ),
            
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBackButton(context),
                    ),
                    
                    // Success Illustration
                    _buildSuccessIllustration(),
                    
                    // Content Section
                    _buildContentSection(),
                    
                    const SizedBox(height: 40),
                    
                    // Sign In Button
                    _buildSignInButton(context),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).maybePop();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFDEDEDE),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1E2021),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFDAF40).withOpacity(0.1),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFDAF40).withOpacity(0.2),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFDAF40),
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      children: [
        // Title
        Text(
          'Password reset\nsuccessful',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: const Color(0xFF3C230C), // #3c230c
            height: 1.2,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Use your new password next time you log in',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: const Color(0xFF1E2021), // #1e2021
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Additional Tips (Added for better UX)
        _buildTipsSection(),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDAF40).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: const Color(0xFFFDAF40),
              ),
              const SizedBox(width: 8),
              Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: const Color(0xFF3C230C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            'Don\'t share your password with anyone',
            Icons.shield_outlined,
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            'Use a unique password for each account',
            Icons.vpn_key_outlined,
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            'Consider using a password manager',
            Icons.security_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF777F84),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: const Color(0xFF777F84),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Container(
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
            // Navigate to sign in screen
            // This would typically navigate to the sign in screen
            // and clear the navigation stack
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.signIn,
              (route) => false,
            );
          },
          child: Center(
            child: Text(
              'Sign in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: const Color(0xFFFFFBF5), // #fffbf5
              ),
            ),
          ),
        ),
      ),
    );
  }
}