// new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import '../controllers/auth_controller.dart';
import 'password_reset_args.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  bool get _passwordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUpperCase &&
      _hasLowerCase &&
      _hasNumber &&
      _hasSpecialChar &&
      _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _savePassword() async {
    final colors = context.appColors;
    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix password requirements'),
          backgroundColor: colors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! NewPasswordArgs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing reset token'),
          backgroundColor: colors.accent,
        ),
      );
      return;
    }

    final auth = ref.read(authFlowControllerProvider.notifier);

    try {
      await auth.resetPassword(
        email: args.email,
        token: args.token,
        password: _newPasswordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.passwordResetSuccess,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(context, UiErrorMessage.from(e));
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
            // Background decorative element
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  width: 234,
                  height: 347,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(150),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 100,
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

                    const SizedBox(height: 30),

                    // Password Requirements
                    _buildRequirements(),

                    const SizedBox(height: 20),

                    // New Password Input
                    _buildNewPasswordInput(),

                    const SizedBox(height: 20),

                    // Confirm Password Input
                    _buildConfirmPasswordInput(),

                    const SizedBox(height: 30),

                    // Password Match Check
                    _buildMatchCheck(),

                    const SizedBox(height: 40),

                    // Save Button
                    _buildSaveButton(),

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
        navigator.pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      },
    );
  }

  Widget _buildTitleSection() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'New password be minimum of 8 characters',
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

  Widget _buildRequirements() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Requirements:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Campton',
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildRequirementItem('At least 8 characters', _hasMinLength),
        const SizedBox(height: 8),
        _buildRequirementItem('One uppercase letter (A-Z)', _hasUpperCase),
        const SizedBox(height: 8),
        _buildRequirementItem('One lowercase letter (a-z)', _hasLowerCase),
        const SizedBox(height: 8),
        _buildRequirementItem('One number (0-9)', _hasNumber),
        const SizedBox(height: 8),
        _buildRequirementItem(
          'One special character (!@#\$...)',
          _hasSpecialChar,
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: isMet ? const Color(0xFF4CAF50) : colors.textTertiary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: isMet ? const Color(0xFF4CAF50) : colors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(
              color: _newPasswordController.text.isEmpty
                  ? colors.border
                  : _hasMinLength
                  ? colors.accent
                  : const Color(0xFFF44336),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your password',
                      hintStyle: TextStyle(color: colors.textTertiary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(
              color: _confirmPasswordController.text.isEmpty
                  ? colors.border
                  : _passwordsMatch
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.lock_reset_rounded,
                  size: 20,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your password',
                      hintStyle: TextStyle(color: colors.textTertiary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCheck() {
    if (_confirmPasswordController.text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          _passwordsMatch
              ? Icons.check_circle_rounded
              : Icons.error_outline_rounded,
          size: 16,
          color: _passwordsMatch
              ? const Color(0xFF4CAF50)
              : const Color(0xFFF44336),
        ),
        const SizedBox(width: 8),
        Text(
          _passwordsMatch ? 'Passwords match' : 'Passwords do not match',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: _passwordsMatch
                ? const Color(0xFF4CAF50)
                : const Color(0xFFF44336),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: _isPasswordValid
            ? colors.accent
            : colors.accent.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isPasswordValid
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
          onTap: _isPasswordValid ? _savePassword : null,
          child: Center(
            child: Text(
              'Save Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: _isPasswordValid
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
