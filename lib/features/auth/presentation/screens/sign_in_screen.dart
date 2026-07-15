// sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import '../controllers/auth_controller.dart';
import 'package:ojaewa/core/auth/google_sign_in_providers.dart';
import 'package:ojaewa/core/errors/app_exception.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'set_referral_code_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  // Default on: the app has always kept sessions signed in across restarts, so
  // keeping this checked preserves that behavior. Unchecking now meaningfully
  // opts out (session kept in memory only), which is what the control implies.
  bool _rememberMe = true;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authFlowControllerProvider);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back Button at the top
              _buildBackButton(),

              // Main Card Content
              _buildSignInCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 24, right: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: WBBackChip(
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
              return;
            }
            navigator.pushNamedAndRemoveUntil(
              AppRoutes.onboarding,
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignInCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),

          // Welcome Image/Icon
          _buildWelcomeIcon(),

          const SizedBox(height: 30),

          // Welcome Text
          _buildWelcomeText(),

          const SizedBox(height: 20),

          // Email Input
          _buildEmailInput(),

          const SizedBox(height: 20),

          // Password Input
          _buildPasswordInput(),

          const SizedBox(height: 20),

          // Forgot Password
          _buildForgotPassword(),

          const SizedBox(height: 20),

          // Remember Me Checkbox
          _buildRememberMe(),

          const SizedBox(height: 40),

          // Sign In Button
          _buildSignInButton(),

          const SizedBox(height: 20),

          // Divider with "or" text
          _buildDivider(),

          const SizedBox(height: 20),

          // Google Sign In Button — temporarily disabled
          // _buildGoogleSignIn(),
          const SizedBox(height: 20),

          // Sign Up Link
          _buildSignUpLink(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeIcon() {
    return const WBWordmark(height: 26);
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.authWelcomeBack, style: WBTypography.hero.copyWith(fontSize: 30)),
        const SizedBox(height: 8),
        Text(
          context.l10n.authLetsSignIn,
          style: WBTypography.body.copyWith(color: WBColors.fgSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    return WBInput(
      label: context.l10n.authEmail,
      placeholder: context.l10n.authEmailHint,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordInput() {
    return WBInput(
      label: context.l10n.authPassword,
      placeholder: context.l10n.authPasswordHint,
      controller: _passwordController,
      obscureText: _obscurePassword,
      trailing: GestureDetector(
        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
        child: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: WBColors.fgSecondary,
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    final colors = context.appColors;
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.resetPassword);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              context.l10n.authForgotPassword,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    final colors = context.appColors;
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: colors.borderStrong, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: colors.surface,
              ),
              child: _rememberMe
                  ? Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: colors.accent,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          context.l10n.authRememberMe,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    final auth = ref.watch(authFlowControllerProvider);
    return WBButton(
      label: context.l10n.authSignIn,
      fullWidth: true,
      size: WBButtonSize.lg,
      loading: auth.isLoading,
      onPressed: _handleSignIn,
    );
  }

  Widget _buildDivider() {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: colors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: colors.border)),
      ],
    );
  }

  Widget _buildGoogleSignIn() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final auth = ref.read(authFlowControllerProvider);
            if (auth.isLoading) return;

            final authFlow = ref.read(authFlowControllerProvider.notifier);
            final google = ref.read(googleSignInServiceProvider);

            try {
              final idToken = await google.signInAndGetIdToken();
              await authFlow.googleSignIn(idToken: idToken);
              if (!mounted) return;

              // Show referral code sheet for Google users
              await SetReferralCodeSheet.show(context);

              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            } on AppException catch (e) {
              // User cancelled - don't show error
              if (e.message.contains('cancelled')) return;
              if (!mounted) return;
              AppSnackbars.showError(context, e.message);
            } catch (e) {
              if (!mounted) return;
              AppSnackbars.showError(context, UiErrorMessage.from(e));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppIcons.google, width: 20, height: 20),
              const SizedBox(width: 16),
              Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    final colors = context.appColors;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.createAccount);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.authNoAccount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textTertiary,
                    ),
                  ),
                  TextSpan(
                    text: context.l10n.authCreateAccount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.authFillFields),
          backgroundColor: WBColors.statusWarning,
        ),
      );
      return;
    }

    try {
      await ref
          .read(authFlowControllerProvider.notifier)
          .login(email: email, password: password, rememberMe: _rememberMe);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(context, UiErrorMessage.from(e));
    }
  }

}
