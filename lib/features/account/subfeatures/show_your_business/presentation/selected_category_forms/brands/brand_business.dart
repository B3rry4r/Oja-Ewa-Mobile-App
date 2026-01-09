import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../../../app/router/app_router.dart';

class BrandBusinessDetailsScreen extends StatelessWidget {
  const BrandBusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(104),
        child: AppHeader(
          backgroundColor: Color(0xFFFFF8F1),
          iconColor: Color(0xFF241508),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProgressStepper(),
            const SizedBox(height: 32),
            
            // About Business Header
            const Text(
              "About Business",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C4042),
              ),
            ),
            const SizedBox(height: 20),

            // Form Fields
            _buildInputField("Business Name", "Your City"),
            const SizedBox(height: 24),
            _buildInputField(
              "Business Decription", 
              "Share Short description of your business",
              maxLines: 4,
              helperText: "100 characters required",
            ),
            const SizedBox(height: 24),
            _buildDropdownField("Select Brand Category", "select"),
            const SizedBox(height: 24),
            _buildInputField("Product  List", "List your services here", maxLines: 4),
            
            const SizedBox(height: 32),

            // Upload Sections
            _buildUploadCard(
              title: "CAC Document",
              hintLeft: "High resolution image\nPDF, JPEG, PNG formats",
              hintRight: "200 x 200px\n20kb Max",
            ),
            const SizedBox(height: 24),
            _buildUploadCard(
              title: "Business logo",
              hintLeft: "High resolution image\nPNG formats",
              hintRight: "200 x 200px\nMust be in Black",
            ),

            const SizedBox(height: 40),
            _buildSubmitButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Row(
      children: [
        _buildStep(Icons.check, "Basic\nInfo", true, isCompleted: true),
        // connector removed (not part of final design)
        const SizedBox(width: 8),
        _buildStep(null, "Business\nDetails", true, stepNum: "2"),
        // connector removed (not part of final design)
        const SizedBox(width: 8),
        _buildStep(null, "Account\non review", false, stepNum: "3"),
      ],
    );
  }

  Widget _buildStep(IconData? icon, String label, bool isActive, {bool isCompleted = false, String? stepNum}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: icon != null 
              ? Icon(icon, color: Colors.white, size: 16)
              : Text(stepNum ?? "", style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF777F84),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Campton',
            color: isActive ? const Color(0xFF603814) : const Color(0xFF777F84),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(helperText, style: const TextStyle(color: Color(0xFF595F63), fontSize: 10)),
          ),
        ]
      ],
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16)),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({required String title, required String hintLeft, required String hintRight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF89858A)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: Color(0xFF603814), size: 30),
              const SizedBox(height: 8),
              const Text(
                "Browse Document",
                style: TextStyle(fontSize: 16, color: Color(0xFF1E2021), fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(hintLeft, style: const TextStyle(color: Color(0xFF777F84), fontSize: 10)),
                    Text(hintRight, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF777F84), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(AppRoutes.businessAccountReview),
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
            )
          ],
        ),
        child: const Center(
          child: Text(
            "Make Payment",
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
