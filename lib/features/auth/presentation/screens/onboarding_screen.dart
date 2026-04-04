// onboarding_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/app/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surfaceSecondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colors.surfaceSecondary, colors.surfaceSecondary],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.asset(
                    AppImages.onboardingHero,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Flexible(flex: 4, child: _buildBottomPanel(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeadline(context),
          const SizedBox(height: 14),
          _buildActionButtons(context),
          const SizedBox(height: 10),
          _buildTermsAndPrivacy(context),
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    final colors = context.appColors;
    return Text(
      'The Pan-African\nBeauty Market',
      style: TextStyle(
        fontSize: 22.5,
        fontWeight: FontWeight.w700,
        fontFamily: 'Campton',
        color: colors.textPrimary,
        height: 1.2,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.createAccount),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              foregroundColor: colors.onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
              ),
            ),
            child: const Text('Create account'),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _secondaryButton(
                context: context,
                label: 'Sign in',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.signIn),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _secondaryButton(
                context: context,
                label: 'Guest',
                onTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _secondaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surfaceElevated,
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'Campton',
            color: colors.textSecondary,
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
                ..onTap = () =>
                    Navigator.of(context).pushNamed(AppRoutes.termsOfService),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: Color(0xFFFDAF40),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}
