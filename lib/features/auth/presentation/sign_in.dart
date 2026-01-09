// sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/core/resources/app_assets.dart';

import '../../../app/router/app_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController(text: 'sanusimot@gmail.com');
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814), // #603814
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              // Handle back navigation
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFDEDEDE), // #dedede
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFF1E2021),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInCard() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1), // #fff8f1
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
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
            
            // Google Sign In Button
            _buildGoogleSignIn(),
            
            const SizedBox(height: 20),
            
            // Sign Up Link
            _buildSignUpLink(),
            
            const SizedBox(height: 40), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeIcon() {
    return SizedBox(
      width: 41.6,
      height: 61.89,
      child: SvgPicture.asset(
        AppImages.appLogo,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: const Color(0xFF3C230C), // #3c230c
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s sign in',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF301C0A), // #301c0a
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF1E2021),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: Color(0xFFCCCCCC),
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
                      hintStyle: TextStyle(
                        color: Color(0xFFCCCCCC),
                      ),
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
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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

  Widget _buildForgotPassword() {
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
              'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: const Color(0xFF000000),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
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
                border: Border.all(
                  color: const Color(0xFF777F84), // #777f84
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _rememberMe
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
        Text(
          'Remember me',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF1E2021), // #1e2021
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Handle sign in
            _handleSignIn();
          },
          child: const Center(
            child: Text(
              'Sign in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: Color(0xFFFFFBF5), // #fffbf5
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
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFB5B5B5),
          ),
        ),
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
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFB5B5B5),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignIn() {
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
          onTap: () {
            // Handle Google sign in
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppIcons.google,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 16),
              Text(
                'Sign in with Google',
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

  Widget _buildSignUpLink() {
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
                    text: 'No account yet? ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF000000),
                    ),
                  ),
                  TextSpan(
                    text: 'Create account',
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

  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Color(0xFFFDAF40),
        ),
      );
      return;
    }
    
    // TODO: Replace with real auth.
    // For now, treat any non-empty email/password as success.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }
}