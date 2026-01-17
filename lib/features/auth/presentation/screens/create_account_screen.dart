// create_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'package:ojaewa/app/router/app_router.dart';
import '../controllers/auth_controller.dart';
import 'package:ojaewa/core/auth/google_sign_in_providers.dart';
import 'package:ojaewa/core/errors/app_exception.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';

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

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  // Phone country code - empty by default
  String _selectedCountryCode = '';
  String _selectedCountryFlag = '';

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
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and agree to terms'),
          backgroundColor: Color(0xFFFDAF40),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await ref
          .read(authFlowControllerProvider.notifier)
          .register(
            firstname: _firstNameController.text.trim(),
            lastname: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
    final auth = _auth;

    return Scaffold(
      backgroundColor: const Color(0xFF603814), // #603814
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
    return HeaderIconButton(
      asset: AppIcons.back,
      iconColor: Colors.white,
      onTap: () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildContentCard() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1), // #fff8f1
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Welcome Icon
            _buildWelcomeIcon(),

            const SizedBox(height: 20),

            // Title
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: const Color(0xFF3C230C), // #3c230c
              ),
            ),

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

            // Password Input
            _buildPasswordInput(),

            const SizedBox(height: 8),

            // Password Requirement Text
            Text(
              'Minimum of 8 characters',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: const Color(0xFF777F84), // #777f84
              ),
            ),

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

            // Google Sign In Button
            _buildGoogleSignInButton(),

            const SizedBox(height: 20),

            // Sign In Link
            _buildSignInLink(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeIcon() {
    return SizedBox(
      width: 41.6,
      height: 63.58,
      child: SvgPicture.asset(AppImages.appLogoAlt, fit: BoxFit.contain),
    );
  }

  Widget _buildFirstNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84), // #777f84
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFCCCCCC), // #cccccc
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your first name',
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
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

  Widget _buildLastNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your last name',
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
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

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84), // #777f84
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFCCCCCC), // #cccccc
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
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

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84), // #777f84
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFCCCCCC), // #cccccc
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Country code selector
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
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Campton',
                            color: const Color(0xFF241508),
                          ),
                        ),
                      ] else
                        Text(
                          'Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Campton',
                            color: const Color(0xFFCCCCCC),
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Color(0xFF777F84),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Phone number input
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Phone number',
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
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

  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84), // #777f84
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(
              color: _passwordController.text.isEmpty
                  ? const Color(0xFFCCCCCC)
                  : _passwordController.text.length >= 8
                  ? const Color(0xFFFDAF40)
                  : const Color(0xFFF44336),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: Color(0xFFCCCCCC),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your password',
                      hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
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
                    color: const Color(0xFF777F84),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
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
                border: Border.all(
                  color: const Color(0xFF777F84), // #777f84
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _agreeToTerms
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Color(0xFFFDAF40),
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
                    fontFamily: 'Campton',
                    color: const Color(0xFF1E2021), // #1e2021
                    height: 1.4,
                  ),
                ),
                TextSpan(
                  text: 'terms of service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: const Color(0xFFFDAF40), // #fdaf40
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
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: _isFormValid
            ? const Color(0xFFFDAF40)
            : const Color(0xFFFDAF40).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: _isFormValid
            ? [
                BoxShadow(
                  color: const Color(0xFFFDAF40).withValues(alpha: 0.3),
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
          onTap: (_isFormValid && !_auth.isLoading) ? _createAccount : null,
          child: Center(
            child: _auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFFBF5),
                    ),
                  )
                : Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                      color: _isFormValid
                          ? const Color(0xFFFFFBF5)
                          : const Color(0xFFFFFBF5).withValues(alpha: 0.6),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFB5B5B5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: const Color(0xFF595F63), // #595f63
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFB5B5B5))),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 49,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCCCCCC), // #cccccc
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
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
                  fontFamily: 'Campton',
                  color: const Color(0xFF1E2021), // #1e2021
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
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
                    text: 'Have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF000000),
                    ),
                  ),
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                      color: const Color(0xFFFDAF40),
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
}
