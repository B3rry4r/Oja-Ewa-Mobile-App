import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/widgets/wb_button.dart';

import 'auth_providers.dart';

/// Guest-first interaction gate (mirrors WAWUBasket's
/// `GuestModeController.requireAccount`).
///
/// Call this BEFORE firing any authenticated request or navigating to an
/// auth-only screen on a gated interaction (add-to-cart, wishlist toggle,
/// start selling, etc.).
///
/// It gates on the ACTUAL access token (via [accessTokenProvider]), not merely
/// a guest flag:
/// - When a usable token exists it returns `true` synchronously and the caller
///   proceeds.
/// - When absent it presents a short prompt ("Sign in" / "Create account" /
///   "Continue as guest"), routes to sign-in / create-account accordingly, and
///   returns `false` so the caller short-circuits BEFORE any network call that
///   would 401.
///
/// Usage:
/// ```dart
/// if (!await ensureSignedIn(context, ref, action: 'add items to your cart')) {
///   return;
/// }
/// // ...proceed with authenticated action
/// ```
Future<bool> ensureSignedIn(
  BuildContext context,
  WidgetRef ref, {
  String? action,
}) async {
  final token = ref.read(accessTokenProvider);
  if (token != null && token.isNotEmpty) return true;

  if (!context.mounted) return false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (sheetContext) => _AuthRequiredSheet(action: action),
  );

  // The user always lands back here as a guest unless they completed sign-in
  // on the pushed route; either way the caller must not proceed with the
  // authenticated action from this tap.
  return false;
}

class _AuthRequiredSheet extends StatelessWidget {
  const _AuthRequiredSheet({this.action});

  final String? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final prompt = action == null
        ? 'Sign in to continue.'
        : 'Sign in to $action.';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                prompt,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in or create an account to continue. You can keep browsing as a guest.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              WBButton(
                label: 'Sign in',
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.signIn);
                },
              ),
              const SizedBox(height: 12),
              WBButton(
                label: 'Create account',
                fullWidth: true,
                variant: WBButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.createAccount);
                },
              ),
              const SizedBox(height: 12),
              WBButton(
                label: 'Continue as guest',
                fullWidth: true,
                variant: WBButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
