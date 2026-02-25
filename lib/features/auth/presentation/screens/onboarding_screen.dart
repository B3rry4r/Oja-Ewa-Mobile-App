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
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(AppImages.coxVideo);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      await controller.setLooping(true);
      await controller.play();
      setState(() => _initialized = true);
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted) setState(() => _initialized = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Full-screen video ──────────────────────────────
          _buildFullScreenVideo(),

          // ── Layer 2: Dark gradient — makes bottom content readable ──
          _buildGradientOverlay(),

          // ── Layer 3: Content on top ─────────────────────────────────
          SafeArea(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Full-screen video (covers the entire Scaffold, edge-to-edge)
  // ──────────────────────────────────────────────────────────────────
  Widget _buildFullScreenVideo() {
    if (!_initialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFDAF40)),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) return const ColoredBox(color: Colors.black);

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Gradient overlay — transparent at top, dark at bottom
  // Keeps headline + buttons readable against any video frame
  // ──────────────────────────────────────────────────────────────────
  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45, 1.0],
          colors: [
            Colors.transparent,
            Colors.transparent,
            Color(0xE6000000), // ~90% black at very bottom
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Content: logo at top, headline + buttons pinned to bottom
  // ──────────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small logo / brand mark at top-left
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Image.asset(
            AppImages.logoOutline,
            height: 36,
            color: Colors.white,
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
          ),
        ),

        // Push everything else to the bottom
        const Spacer(),

        // Headline + buttons + T&C
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeadline(),
              const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 16),
              _buildTermsAndPrivacy(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return const Text(
      'The Pan-African\nBeauty Market',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontFamily: 'Campton',
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary CTA — Create account
        SizedBox(
          width: double.infinity,
          height: 57,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.createAccount),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              foregroundColor: const Color(0xFFFFFBF5),
              elevation: 8,
              shadowColor: const Color(0xFFFDAF40).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
              ),
            ),
            child: const Text('Create account'),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary row — Sign in + Continue as guest
        Row(
          children: [
            Expanded(
              child: _outlineButton(
                label: 'Sign in',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.signIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outlineButton(
                label: 'Continue as guest',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _outlineButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 57,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFDAF40),
          side: const BorderSide(color: Color(0xFFFDAF40), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
          ),
        ),
        child: Text(label),
      ),
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
            color: Color(0xCCFFFFFF), // white with slight transparency
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
