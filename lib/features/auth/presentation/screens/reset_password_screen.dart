import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/app/router/app_router.dart';
import '../controllers/auth_controller.dart';
import 'password_reset_args.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 74),

                // Back Button
                _buildBackButton(context),

                const SizedBox(height: 49),

                // Title
                Text(
                  'Reset password',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 33,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -1,
                    color: colors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Instructions
                Text(
                  'Enter your registered email',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 37),

                // Email Input Group
                _buildEmailInputGroup(),

                const SizedBox(height: 146),

                // Send Code Button
                _buildSendCodeButton(context),

                const SizedBox(height: 246),

                // Decorative Background Image (low opacity)
                _buildBackgroundImage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return HeaderIconButton(
      asset: AppIcons.back,
      iconColor: context.appColors.textPrimary,
      onTap: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        navigator.pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      },
    );
  }

  Widget _buildEmailInputGroup() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Label
        Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3,
            color: colors.textTertiary,
          ),
        ),

        const SizedBox(height: 8),

        // Email Input Field
        SizedBox(
          height: 49,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'sanusimot@gmail.com',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: colors.textTertiary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.accent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton(BuildContext context) {
    final colors = context.appColors;
    final auth = ref.watch(authFlowControllerProvider);

    return GestureDetector(
      onTap: auth.isLoading
          ? null
          : () async {
              final email = _emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter your email'),
                    backgroundColor: colors.accent,
                  ),
                );
                return;
              }

              try {
                await ref
                    .read(authFlowControllerProvider.notifier)
                    .forgotPassword(email: email);
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(
                  AppRoutes.verificationCode,
                  arguments: PasswordResetArgs(email: email),
                );
              } catch (e) {
                if (!context.mounted) return;
                AppSnackbars.showError(context, UiErrorMessage.from(e));
              }
            },
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.2),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Center(
          child: auth.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFFBF5),
                  ),
                )
              : Text(
                  'Send code',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: const Color(0xFFFFFBF5), // #fffbf5
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Opacity(
      opacity: 0.03, // 3% opacity as per IR
      child: const AppImagePlaceholder(
        width: 234,
        height: 347,
        borderRadius: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
