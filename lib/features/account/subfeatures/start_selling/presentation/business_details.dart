// business_details_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

import '../../../../../app/router/app_router.dart';
import 'draft_utils.dart';

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
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildStepper(),
          const SizedBox(height: 40),

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
    final colors = context.appColors;
    final Color activeColor = colors.textPrimary;
    final Color inactiveColor = colors.borderStrong;

    final Color boxColor = isActive || isComplete ? activeColor : inactiveColor;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: isComplete
              ? Icon(Icons.check, color: colors.background, size: 16)
              : Text(
                  num.toString(),
                  style: TextStyle(
                    color: colors.background,
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
    final colors = context.appColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextInput(
    String label,
    String hint, {
    TextEditingController? controller,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: colors.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final colors = context.appColors;
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Continue",
            style: TextStyle(
              color: colors.onAccent,
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
