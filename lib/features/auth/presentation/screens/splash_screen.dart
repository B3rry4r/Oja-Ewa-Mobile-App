// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Show the splash for at least 1 second, then wait for auth to resolve.
    Future.delayed(const Duration(seconds: 1), _tryNavigate);
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;

    final authState = ref.read(authControllerProvider);

    // If auth is still unknown (e.g. loadFromStorage() hasn't finished yet),
    // wait for it to change before navigating. This should never happen in
    // practice because main() calls loadFromStorage() before runApp(), but
    // this guard makes the splash rock-solid against any timing edge cases.
    if (authState is AuthUnknown) {
      // Listen for the next state change and navigate then.
      ref.listenManual(authControllerProvider, (_, next) {
        if (next is! AuthUnknown) {
          _navigate(next);
        }
      }, fireImmediately: false);
      return;
    }

    _navigate(authState);
  }

  void _navigate(AuthState authState) {
    if (!mounted || _navigated) return;
    _navigated = true;

    final nextRoute =
        authState is AuthAuthenticated ? AppRoutes.home : AppRoutes.onboarding;

    Navigator.of(context).pushReplacementNamed(nextRoute);
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
        // Complete logo with text (PNG for correct colors)
        Image.asset(
          'assets/app_icon/logo2.png',
          width: 200,
          height: 60,
          fit: BoxFit.contain,
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
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
      ],
    );
  }
}
