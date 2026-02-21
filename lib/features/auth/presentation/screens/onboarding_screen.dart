// onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:video_player/video_player.dart';

import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/app/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(AppImages.coxVideo)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            // Hero video - expands to fill available space
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
        // Hero Video
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: SizedBox.expand(
            child: _initialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFDAF40),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

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
                    color: Color(0xFFFFFBF5),
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
