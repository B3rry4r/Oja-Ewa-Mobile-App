// password_reset_success_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
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
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(150),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 120,
                      color: colors.accent,
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
                    _buildSuccessIllustration(context),

                    // Content Section
                    _buildContentSection(context),

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
    return HeaderIconButton(
      asset: AppIcons.back,
      iconColor: context.appColors.textPrimary,
      onTap: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        navigator.pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      },
    );
  }

  Widget _buildSuccessIllustration(BuildContext context) {
    final colors = context.appColors;
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
              color: colors.accent.withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent,
            ),
            child: Center(
              child: Icon(
                Icons.check_rounded,
                size: 60,
                color: colors.onAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final colors = context.appColors;
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
            color: colors.textPrimary,
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
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Additional Tips (Added for better UX)
        _buildTipsSection(context),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                color: colors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            context,
            'Don\'t share your password with anyone',
            Icons.shield_outlined,
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            context,
            'Use a unique password for each account',
            Icons.vpn_key_outlined,
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            context,
            'Consider using a password manager',
            Icons.security_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text, IconData icon) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: colors.textTertiary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(8),
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
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Navigate to sign in screen
            // This would typically navigate to the sign in screen
            // and clear the navigation stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
          },
          child: Center(
            child: Text(
              'Sign in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
