import 'package:flutter/material.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';

/// Full-screen offline state that blocks interaction when there is no network.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: 24),
                Text(
                  'You\'re offline',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect to the internet to continue. We\'ll refresh automatically when you\'re back online.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    color: colors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
