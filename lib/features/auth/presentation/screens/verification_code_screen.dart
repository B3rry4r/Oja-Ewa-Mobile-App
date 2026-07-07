// verification_code_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import '../controllers/auth_controller.dart';
import 'password_reset_args.dart';

class VerificationCodeScreen extends ConsumerStatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  ConsumerState<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends ConsumerState<VerificationCodeScreen> {
  // WAWU ID issues 6-digit reset codes (and the OTP_BYPASS_CODE is 6 digits).
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String _enteredCode = '';

  @override
  void initState() {
    super.initState();
    // Set up focus node listeners for auto-advancing
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && i < _focusNodes.length - 1) {
          // Move to next field when current is filled
          if (_codeControllers[i].text.isNotEmpty) {
            _focusNodes[i + 1].requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateCode() {
    setState(() {
      _enteredCode = _codeControllers.map((c) => c.text).join();
      if (_enteredCode.length == 6) {
        // Auto-submit or verify when all digits are entered
        _verifyCode();
      }
    });
  }

  void _verifyCode() {
    if (_enteredCode.length != 6) return;
    final colors = context.appColors;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! PasswordResetArgs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing phone number for reset flow'),
          backgroundColor: colors.accent,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.newPassword,
      arguments:
          NewPasswordArgs(identifier: args.identifier, token: _enteredCode),
    );
  }

  Future<void> _resendCode() async {
    final colors = context.appColors;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! PasswordResetArgs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing details to resend the code'),
          backgroundColor: colors.accent,
        ),
      );
      return;
    }

    // Actually re-request a code from WAWU ID (previously this was a no-op that
    // only showed a fake "code sent" message).
    try {
      await ref
          .read(authFlowControllerProvider.notifier)
          .forgotPassword(identifier: args.identifier);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A new code has been sent'),
          backgroundColor: colors.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not resend the code. Please try again.'),
          backgroundColor: colors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative image with low opacity
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  width: 307,
                  height: 455,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(150),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 120,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // Back Button
                    _buildBackButton(),

                    const SizedBox(height: 40),

                    // Title Section
                    _buildTitleSection(),

                    const SizedBox(height: 50),

                    // Code Input Fields
                    _buildCodeInputFields(),

                    const SizedBox(height: 60),

                    // Resend Code Section
                    _buildResendCodeSection(),

                    const SizedBox(height: 60),

                    // Verify Button (added for better UX)
                    _buildVerifyButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return HeaderIconButton(
      asset: AppIcons.back,
      iconColor: context.appColors.textPrimary,
      onTap: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        navigator.pushNamedAndRemoveUntil(
          AppRoutes.resetPassword,
          (route) => false,
        );
      },
    );
  }

  Widget _buildTitleSection() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code sent!',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the six-digit code sent to your email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputFields() {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 46,
          height: 60,
          child: TextField(
            controller: _codeControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.accent, width: 2),
              ),
              filled: true,
              fillColor: colors.surface,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                // Auto-advance to next field
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                // Auto-move back when deleting
                _focusNodes[index - 1].requestFocus();
              }
              _updateCode();
            },
            onTap: () {
              // Clear field when tapped if it has a value
              if (_codeControllers[index].text.isNotEmpty) {
                _codeControllers[index].clear();
                _updateCode();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendCodeSection() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Didn\'t receive code?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: _resendCode,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                'Resend code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.accent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    final colors = context.appColors;
    final isComplete = _enteredCode.length == 6;

    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: isComplete
            ? colors.accent
            : colors.accent.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isComplete ? _verifyCode : null,
          child: Center(
            child: Text(
              'Verify',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isComplete
                    ? colors.onAccent
                    : colors.onAccent.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
