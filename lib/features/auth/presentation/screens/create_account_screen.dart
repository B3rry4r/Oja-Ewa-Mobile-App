// create_account_screen.dart
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
import 'package:ojaewa/core/location/location_picker_sheets.dart';
import 'set_referral_code_screen.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  late AsyncValue<void> _auth;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  // Optional canonical identity gender (lowercase 'male'|'female'); null = unset.
  String? _selectedGender;
  // Phone country code - empty by default
  String _selectedCountryCode = '';
  String _selectedCountryFlag = '';
  String _selectedCountryName = '';

  bool get _isFormValid =>
      _firstNameController.text.isNotEmpty &&
      _lastNameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty &&
      _passwordController.text.length >= 8 &&
      _agreeToTerms;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.authFillFields),
          backgroundColor: WBColors.statusWarning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final referralCode = _referralCodeController.text.trim();

      await ref
          .read(authFlowControllerProvider.notifier)
          .register(
            firstname: _firstNameController.text.trim(),
            lastname: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone:
                '${_selectedCountryCode.isNotEmpty ? _selectedCountryCode : '+234'}${_phoneController.text.replaceAll(RegExp(r'\D'), '')}',
            country: _selectedCountryName.isNotEmpty
                ? _selectedCountryName
                : 'Nigeria',
            referralCode: referralCode.isNotEmpty ? referralCode : null,
            gender: _selectedGender,
          );

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Account created successfully');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(context, UiErrorMessage.from(e));
    }
  }

  Future<void> _signInWithGoogle() async {
    final authFlow = ref.read(authFlowControllerProvider.notifier);
    final google = ref.read(googleSignInServiceProvider);

    try {
      final idToken = await google.signInAndGetIdToken();
      await authFlow.googleSignIn(idToken: idToken);
      if (!mounted) return;

      // Show referral code sheet for new Google users
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
  }

  void _navigateToSignIn() {
    // Navigate to sign in screen
    Navigator.of(context).pushNamed(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    _auth = ref.watch(authFlowControllerProvider);
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 20, right: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildBackButton(),
                ),
              ),

              // Main Content Card
              _buildContentCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return WBBackChip(
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
    );
  }

  Widget _buildContentCard() {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),

          // Welcome Icon
          _buildWelcomeIcon(),

          const SizedBox(height: 20),

          // Title
          Text(context.l10n.authCreateAccountTitle, style: WBTypography.hero.copyWith(fontSize: 30)),

          const SizedBox(height: 20),

          // First/Last Name Inputs
          _buildFirstNameInput(),

          const SizedBox(height: 20),

          _buildLastNameInput(),

          const SizedBox(height: 20),

          // Email Input
          _buildEmailInput(),

          const SizedBox(height: 20),

          // Phone Number Input
          _buildPhoneInput(),

          const SizedBox(height: 20),

          // Gender Selector (Optional)
          _buildGenderSelector(),

          const SizedBox(height: 20),

          // Password Input
          _buildPasswordInput(),

          const SizedBox(height: 8),

          // Password Requirement Text
          Text(
            context.l10n.authMinChars,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Referral Code Input (Optional)
          _buildReferralCodeInput(),

          const SizedBox(height: 20),

          // Terms Agreement
          _buildTermsAgreement(),

          const SizedBox(height: 40),

          // Create Account Button
          _buildCreateAccountButton(),

          const SizedBox(height: 20),

          // Divider with "or"
          _buildDivider(),

          const SizedBox(height: 20),

          // Google Sign In Button — temporarily disabled
          // _buildGoogleSignInButton(),
          const SizedBox(height: 20),

          // Sign In Link
          _buildSignInLink(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeIcon() {
    return const WBWordmark(height: 26);
  }

  Widget _buildFirstNameInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authFirstName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputShell(
          icon: Icons.person_outline_rounded,
          child: TextField(
            controller: _firstNameController,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.authFirstNameHint,
              hintStyle: TextStyle(color: colors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastNameInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authLastName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputShell(
          icon: Icons.person_outline_rounded,
          child: TextField(
            controller: _lastNameController,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.authLastNameHint,
              hintStyle: TextStyle(color: colors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authEmail,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputShell(
          icon: Icons.email_outlined,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.authEmailHint,
              hintStyle: TextStyle(color: colors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authPhone,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputShell(
          icon: Icons.phone_outlined,
          child: Row(
            children: [
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
                      _selectedCountryName = country.name;
                    });
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedCountryCode.isNotEmpty) ...[
                      Text(
                        _selectedCountryFlag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountryCode,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ] else
                      Text(
                        'Code',
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.textTertiary,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone number',
                    hintStyle: TextStyle(color: colors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildGenderOption('male', 'Male')),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderOption('female', 'Female')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, String label) {
    final colors = context.appColors;
    final selected = _selectedGender == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(WBRadius.input),
        // Tapping the selected option clears it (gender is optional).
        onTap: () {
          setState(() {
            _selectedGender = selected ? null : value;
          });
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: WBColors.surfaceInput,
            borderRadius: BorderRadius.circular(WBRadius.input),
            border: Border.all(
              color: selected ? colors.accent : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == 'male' ? Icons.male_rounded : Icons.female_rounded,
                size: 20,
                color: selected ? colors.accent : WBColors.fgPlaceholder,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selected ? colors.accent : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authPassword,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputShell(
          icon: Icons.lock_outline_rounded,
          borderColor: _passwordController.text.isEmpty
              ? colors.border
              : _passwordController.text.length >= 8
              ? colors.accent
              : Colors.redAccent,
          trailing: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: colors.textSecondary,
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.authPasswordHint,
              hintStyle: TextStyle(color: colors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: colors.borderStrong, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: colors.surface,
              ),
              child: _agreeToTerms
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
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'By creating account, you agree to \nour ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
                WidgetSpan(
                  child: InkWell(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.termsOfService),
                    child: Text(
                      'terms of service',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return WBButton(
      label: context.l10n.authCreateAccountTitle,
      fullWidth: true,
      size: WBButtonSize.lg,
      disabled: !_isFormValid,
      loading: _auth.isLoading,
      onPressed: _createAccount,
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

  Widget _buildGoogleSignInButton() {
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
          onTap: _auth.isLoading ? null : _signInWithGoogle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppIcons.google, width: 20, height: 20),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
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

  Widget _buildReferralCodeInput() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authReferralOptional,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputShell(
          icon: Icons.card_giftcard_outlined,
          child: TextField(
            controller: _referralCodeController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.l10n.authReferralHint,
              hintStyle: TextStyle(color: colors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    final colors = context.appColors;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: _navigateToSignIn,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.authHaveAccount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textTertiary,
                    ),
                  ),
                  TextSpan(
                    text: context.l10n.authSignIn,
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

  Widget _buildInputShell({
    required IconData icon,
    required Widget child,
    Widget? trailing,
    Color? borderColor,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: WBColors.surfaceInput,
        borderRadius: BorderRadius.circular(WBRadius.input),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: WBColors.fgPlaceholder),
            const SizedBox(width: 12),
            Expanded(child: child),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }
}
