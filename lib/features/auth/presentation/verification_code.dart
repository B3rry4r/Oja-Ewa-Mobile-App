// verification_code_screen.dart
import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
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
      if (_enteredCode.length == 4) {
        // Auto-submit or verify when all digits are entered
        _verifyCode();
      }
    });
  }

  void _verifyCode() {
    // TODO: Replace with real verification.
    // For now, if code is 4 digits, proceed.
    if (_enteredCode.length != 4) return;

    Navigator.of(context).pushNamed(AppRoutes.newPassword);
  }

  void _resendCode() {
    // Handle resend code logic
    print('Resending code...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New code sent to your email'),
        backgroundColor: Color(0xFFFDAF40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // #fff8f1
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
                    color: const Color(0xFFFDAF40).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(150),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 120,
                      color: Color(0xFFFDAF40),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFDEDEDE),
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
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code sent!',
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w600,
            fontFamily: 'Campton',
            color: const Color(0xFF3C230C), // #3c230c
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the four digits sent to your email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF1E2021), // #1e2021
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
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
              fontFamily: 'Campton',
              color: const Color(0xFF1E2021),
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFDEDEDE),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFDEDEDE),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFDAF40),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Didn\'t receive code?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84), // #777f84
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
                  fontFamily: 'Campton',
                  color: const Color(0xFFFDAF40), // #fdaf40
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    final isComplete = _enteredCode.length == 4;
    
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFFDAF40) : const Color(0xFFFDAF40).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color: const Color(0xFFFDAF40).withOpacity(0.3),
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
                fontFamily: 'Campton',
                color: isComplete ? const Color(0xFFFFFBF5) : const Color(0xFFFFFBF5).withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}