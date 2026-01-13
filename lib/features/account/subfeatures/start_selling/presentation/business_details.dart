// business_details_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';
import 'draft_utils.dart';
import 'seller_registration_draft.dart';

class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _businessNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _registrationNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildStepper(),
                  const SizedBox(height: 40),

                  // About Business
                  _buildSectionHeader("About Business"),
                  const SizedBox(height: 16),
                  _buildTextInput(
                    "Business Name",
                    "Enter business name",
                    controller: _businessNameController,
                  ),
                  const SizedBox(height: 20),
                  _buildTextInput(
                    "Business Registration Number",
                    "Enter registration number",
                    controller: _registrationNumberController,
                  ),

                  const SizedBox(height: 40),

                  // Account Details
                  _buildSectionHeader("Account Details"),
                  const SizedBox(height: 16),
                  _buildTextInput(
                    "Bank Name",
                    "Your Bank",
                    controller: _bankNameController,
                  ),
                  const SizedBox(height: 20),
                  _buildTextInput(
                    "Account Number",
                    "Your Account Number",
                    controller: _accountNumberController,
                  ),

                  const SizedBox(height: 48),

                  _buildSubmitButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    final Color inactiveColor = const Color(0xFFCCCCCC);

    final Color boxColor = isActive || isComplete ? activeColor : inactiveColor;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: boxColor,
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
            color: isActive || isComplete ? activeColor : inactiveColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w600,
          color: Color(0xFF241508),
        ),
      ),
    );
  }

  Widget _buildTextInput(
    String label,
    String hint, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFDAF40)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final draft =
            sellerDraftFromArgs(ModalRoute.of(context)?.settings.arguments)
              ..businessName = _businessNameController.text.trim()
              ..businessRegistrationNumber = _registrationNumberController.text
                  .trim()
              ..bankName = _bankNameController.text.trim()
              ..accountNumber = _accountNumberController.text.trim();

        Navigator.of(
          context,
        ).pushNamed(AppRoutes.accountReview, arguments: draft.toJson());
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
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
            "Continue",
            style: TextStyle(
              color: Color(0xFFFFFBF5),
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
