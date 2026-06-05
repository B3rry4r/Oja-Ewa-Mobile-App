import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '';
  String _selectedCountryFlag = '';

  /// The account phone in E.164, e.g. `+2348034211820`. The reset code is
  /// texted here, so this is the identifier we send to WAWU ID.
  String get _e164Phone {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    final dial = _selectedCountryCode.isNotEmpty ? _selectedCountryCode : '+234';
    return '$dial$local';
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
                  'Enter your registered phone number — we\'ll text you a '
                  '6-digit code.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 37),

                // Phone Input Group
                _buildPhoneInputGroup(),

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

  Widget _buildPhoneInputGroup() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone Label
        Text(
          'Phone number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3,
            color: colors.textTertiary,
          ),
        ),

        const SizedBox(height: 8),

        // Phone Input Field (country picker + number)
        SizedBox(
          height: 49,
          child: Row(
            children: [
              // Country code picker
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final country = await CountryCodePickerSheet.show(
                    context,
                    selectedDialCode: _selectedCountryCode,
                  );
                  if (country != null) {
                    setState(() {
                      _selectedCountryCode = country.dialCode;
                      _selectedCountryFlag = country.flag;
                    });
                  }
                },
                child: Container(
                  height: 49,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountryFlag.isNotEmpty
                            ? '$_selectedCountryFlag '
                                '${_selectedCountryCode.isNotEmpty ? _selectedCountryCode : '+234'}'
                            : '+234',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          size: 18, color: colors.textTertiary),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Local number
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '803 421 1820',
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
              if (_phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter your phone number'),
                    backgroundColor: colors.accent,
                  ),
                );
                return;
              }

              final phone = _e164Phone;
              try {
                await ref
                    .read(authFlowControllerProvider.notifier)
                    .forgotPassword(identifier: phone);
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(
                  AppRoutes.verificationCode,
                  arguments: PasswordResetArgs(identifier: phone),
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
