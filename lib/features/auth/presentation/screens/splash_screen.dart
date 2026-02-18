// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import '../../../../core/auth/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final token = ref.read(accessTokenProvider);
      final nextRoute = token == null ? AppRoutes.onboarding : AppRoutes.home;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBrandLogo(),
            const SizedBox(height: 48),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Large outline logo in the background
        Opacity(
          opacity: 0.12,
          child: Image.asset(
            AppImages.logoOutline,
            width: 280,
            height: 280,
            fit: BoxFit.contain,
          ),
        ),
        // Complete logo with text from logo2.svg (wider to accommodate text)
        SvgPicture.asset(
          AppImages.appLogoAlt,
          width: 200, // Wider to show logo + text properly
          height: 60,
          fit: BoxFit.contain,
          // Use original colors from SVG file
          colorFilter: null,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFDAF40)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84),
          ),
        ),
      ],
    );
  }
}

