// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
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
          _navigate();
        }
      }, fireImmediately: false);
      return;
    }

    _navigate();
  }

  void _navigate() {
    if (!mounted || _navigated) return;
    _navigated = true;

    // Guest-first launch: home is ALWAYS the post-splash destination, whether
    // the session restored (authenticated) or not (guest). Onboarding is never
    // the launch destination — it is reached only via the interaction gate or
    // an explicit "Sign in" tap.
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WBColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WBWordmark(height: 72),
            const SizedBox(height: 48),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(WBColors.surfaceDark),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading...',
          style: WBTypography.secondary.copyWith(color: WBColors.fgSecondary),
        ),
      ],
    );
  }
}
