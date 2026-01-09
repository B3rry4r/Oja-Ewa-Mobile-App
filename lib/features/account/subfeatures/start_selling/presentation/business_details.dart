import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';
class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStepper(), // Row-based stepper
                  const SizedBox(height: 32),

                  // --- About Business Section ---
                  _buildSectionHeader("About Business"),
                  const SizedBox(height: 16),
                  _buildTextInput("Business Name", "Your City"), // Hint from IR data
                  const SizedBox(height: 20),
                  _buildTextInput(
                    "Business Registration Number",
                    "Your City",
                  ),

                  const SizedBox(height: 32),
                  _buildFileUploadSection(
                    label: "Business Certificate",
                    subtext1: "High resolution image\nPDF, JPG, PNG formats",
                    subtext2: "200 x 200px\n20kb max",
                  ),

                  const SizedBox(height: 32),
                  _buildFileUploadSection(
                    label: "Business Logo",
                    subtext1: "High resolution image\nPNG format",
                    subtext2: "200 x 200px\nMust be in Black", // Specific requirement
                  ),

                  const SizedBox(height: 40),

                  // --- Account Details Section ---
                  _buildSectionHeader("Account Details"),
                  const SizedBox(height: 16),
                  _buildTextInput("Bank Name", "Your Bank"),
                  const SizedBox(height: 20),
                  _buildTextInput("Account Number", "Your Account Number"),

                  const SizedBox(height: 48),

                  // --- Primary Action Button ---
                  _buildPaymentButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row-based Stepper to match your UI update
  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepItem(1, "Basic\nInfo", isComplete: true, isActive: false),
        _stepItem(2, "Business\nDetails", isComplete: false, isActive: true),
        _stepItem(3, "Account\non review", isComplete: false, isActive: false),
      ],
    );
  }

  Widget _stepItem(
    int num,
    String label, {
    required bool isComplete,
    required bool isActive,
  }) {
    final Color activeColor = const Color(0xFF603814);
    final Color inactiveColor = const Color(0xFFE9E9E9);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (isActive || isComplete) ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: isComplete
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  num.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            height: 1.2,
            color: (isActive || isComplete)
                ? activeColor
                : const Color(0xFF777F84),
            fontWeight: (isActive || isComplete)
                ? FontWeight.w500
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3C4042),
      ),
    );
  }

  Widget _buildTextInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection({
    required String label,
    required String subtext1,
    required String subtext2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 137,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFF89858A)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 24,
                color: Color(0xFF777F84),
              ),
              const SizedBox(height: 8),
              const Text(
                "Browse Document",
                style: TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subtext1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF777F84),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    subtext2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF777F84),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.accountReview),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40), // Primary Orange
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Make Payment", // Button text from Step 2 IR
            style: TextStyle(
              color: Color(0xFFFFFBF5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}