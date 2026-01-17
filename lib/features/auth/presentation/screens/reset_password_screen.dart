import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #fff8f1
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
                    color: const Color(0xFF3C230C), // #3c230c
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
                    color: const Color(0xFF1E2021), // #1e2021
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
      iconColor: const Color(0xFF241508),
      onTap: () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildEmailInputGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Label
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3,
            color: Color(0xFF777F84),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: Color(0xFF1E2021),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'sanusimot@gmail.com',
              hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Color(0xFFCCCCCC),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF603814)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton(BuildContext context) {
    final auth = ref.watch(authFlowControllerProvider);

    return GestureDetector(
      onTap: auth.isLoading
          ? null
          : () async {
              final email = _emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your email'),
                    backgroundColor: Color(0xFFFDAF40),
                  ),
                );
                return;
              }

              try {
                await ref
                    .read(authFlowControllerProvider.notifier)
                    .forgotPassword(email: email);
                if (!mounted) return;
                Navigator.of(context).pushNamed(
                  AppRoutes.verificationCode,
                  arguments: PasswordResetArgs(email: email),
                );
              } catch (e) {
                if (!mounted) return;
                AppSnackbars.showError(context, UiErrorMessage.from(e));
              }
            },
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40), // #fdaf40
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFFDAF40,
              ).withValues(alpha: 0.2), // #fdaf40 with 20% opacity
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
