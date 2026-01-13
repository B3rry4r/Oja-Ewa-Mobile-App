import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../../../app/router/app_router.dart';
import '../classes_offered_editor.dart';

class SchoolBusinessDetailsScreen extends StatefulWidget {
  const SchoolBusinessDetailsScreen({super.key});

  @override
  State<SchoolBusinessDetailsScreen> createState() => _SchoolBusinessDetailsScreenState();
}

class _SchoolBusinessDetailsScreenState extends State<SchoolBusinessDetailsScreen> {
  String _selectedSchoolType = "Fashion";

  final List<ClassOfferedItem> _classes = [ClassOfferedItem()];

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
            _buildStepperHeader(),
            const SizedBox(height: 32),
            
            const Text(
              "About Business",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C4042),
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField("School Name", "Your City"),
            const SizedBox(height: 24),

            const Text(
              "School Type",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            ),
            const SizedBox(height: 8),
            _buildSchoolTypeGrid(),
            
            const SizedBox(height: 24),
            _buildInputField(
              "School Biography", 
              "Share Short description of your business",
              maxLines: 3,
              helperText: "100 characters required",
            ),
            const SizedBox(height: 24),
            const Text(
              "Classes offered",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            ),
            const SizedBox(height: 8),
            ClassesOfferedEditor(items: _classes),
            
            const SizedBox(height: 32),
            _buildLogoUploadSection(),

            const SizedBox(height: 40),
            _buildPaymentButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(Icons.check, "Basic\nInfo", true),
        _buildStep(null, "Business\nDetails", true, stepNumber: "2"),
        _buildStep(null, "Account\non review", false, stepNumber: "3"),
      ],
    );
  }

  Widget _buildStep(IconData? icon, String label, bool isActive, {String? stepNumber}) {
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
              : Text(stepNumber ?? "", style: TextStyle(color: isActive ? Colors.white : const Color(0xFF777F84), fontSize: 10)),
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
        )
      ],
    );
  }

  Widget _buildSchoolTypeGrid() {
    final types = ["Fashion", "Music", "Catering", "Beauty"];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        final isSelected = _selectedSchoolType == type;
        return InkWell(
          onTap: () => setState(() => _selectedSchoolType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFFA15E22) : const Color(0xFF777F84),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 18,
                  color: isSelected ? const Color(0xFFA15E22) : const Color(0xFF777F84),
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyle(
                    color: const Color(0xFF241508),
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            contentPadding: const EdgeInsets.all(16),
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
        if (helperText != null) 
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(helperText, style: const TextStyle(fontSize: 10, color: Color(0xFF595F63))),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Business logo", style: TextStyle(color: Color(0xFF777F84), fontSize: 14)),
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
              const Icon(Icons.cloud_upload_outlined, color: Color(0xFF603814), size: 28),
              const SizedBox(height: 8),
              const Text("Browse Document", style: TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("High resolution image\nPNG formats", style: TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                    Text("200 x 200px\nMust be in Black", textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
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