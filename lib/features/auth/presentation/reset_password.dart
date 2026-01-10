import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import '../../../app/router/app_router.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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

        // Email Input Field (real input, not a static container)
        SizedBox(
          height: 49,
          child: TextField(
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.verificationCode);
      },
      child: Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40), // #fdaf40
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.2), // #fdaf40 with 20% opacity
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Center(
        child: Text(
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