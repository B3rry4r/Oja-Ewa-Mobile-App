import 'package:flutter/material.dart';

import '../../../../../app/router/app_router.dart';

class SellerRegistrationScreen extends StatelessWidget {
  const SellerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background from IR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: _IconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 10),
            child: _IconButton(
              icon: Icons.close,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildStepper(),
            const SizedBox(height: 32),
            
            // --- Location Section ---
            _buildSectionHeader("Location"),
            const SizedBox(height: 16),
            _buildDropdownInput("Country", "Nigeria"),
            const SizedBox(height: 20),
            _buildDropdownInput("State", "FCT"),
            const SizedBox(height: 20),
            _buildTextInput("City", "Your City"),
            const SizedBox(height: 20),
            _buildTextInput("Address Line", "Street, house number etc"),
            
            const SizedBox(height: 40),
            
            // --- Contacts Section ---
            _buildSectionHeader("Contacts"),
            const SizedBox(height: 16),
            _buildTextInput("Business Email", "sanusimot@gmail.com"),
            const SizedBox(height: 20),
            _buildPhoneInput("Business Phone Number", "+234", "8167654354"),
            
            const SizedBox(height: 40),
            
            // --- Social handles Section ---
            _buildSectionHeader("Social handles"),
            const SizedBox(height: 16),
            _buildTextInput("Instagram", "Your Instagram URL"),
            const SizedBox(height: 20),
            _buildTextInput("Facebook", "Your Facebook URL"),
            
            const SizedBox(height: 40),
            
            // --- Means Identification Section ---
            _buildSectionHeader("Means Identification"),
            const SizedBox(height: 16),
            _buildFileUploadSection(),
            
            const SizedBox(height: 40),
            
            // --- Save Button ---
            _buildSubmitButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper: Stepper UI
  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepCircle("1", "Basic\nInfo", true),
        _stepCircle("2", "Business\nDetails", false),
        _stepCircle("3", "Account\non review", false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: isActive ? const Color(0xFF603814) : const Color(0xFF777F84),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
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
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(String label, String code, String number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag, size: 20), // Placeholder for flag asset
              const SizedBox(width: 8),
              Text(code, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(number, style: const TextStyle(fontSize: 16, color: Color(0xFFCCCCCC))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload Document", style: TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFF89858A), style: BorderStyle.solid), // IR indicates dashed-like border
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 24, color: Color(0xFF777F84)),
              const SizedBox(height: 12),
              const Text("Browse Document", style: TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("High resolution image\nPDF, JPG, PNG formats", 
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                  SizedBox(width: 20),
                  Text("200 x 200px\n20kb max", 
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.businessDetails),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 56,
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
            'Save and Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Icon Button helper for top navigation
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}