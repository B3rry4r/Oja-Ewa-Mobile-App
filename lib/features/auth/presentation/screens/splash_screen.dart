// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
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

    final nextRoute = authState is AuthAuthenticated
        ? AppRoutes.home
        : AppRoutes.onboarding;

    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBrandLogo(),
            const SizedBox(height: 48),
            _buildLoadingIndicator(context),
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
        SvgPicture.asset(
          AppIcons.brandMarkWhite,
          width: 200,
          height: 46,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
