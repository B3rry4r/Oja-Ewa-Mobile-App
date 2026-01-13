import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../../../app/router/app_router.dart';
import '../service_list_editor.dart';

class BeautyBusinessDetailsScreen extends StatefulWidget {
  const BeautyBusinessDetailsScreen({super.key});

  @override
  State<BeautyBusinessDetailsScreen> createState() => _BeautyBusinessDetailsScreenState();
}

class _BeautyBusinessDetailsScreenState extends State<BeautyBusinessDetailsScreen> {
  String _selectedOffering = "Selling Product";

  final TextEditingController _professionalTitleController = TextEditingController();
  final List<ServiceListItem> _services = [ServiceListItem()];

  @override
  void dispose() {
    _professionalTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
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
            _buildInputField("Business Name", "Enter business name"),
            const SizedBox(height: 24),
            
            // Type of Offering Section
            const Text(
              "Select type of offering",
              style: TextStyle(color: Color(0xFF777F84), fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildOfferingOption("Selling Product", Icons.shopping_bag_outlined),
            const SizedBox(height: 8),
            _buildOfferingOption("Providing Service", Icons.build_circle_outlined),
            
            const SizedBox(height: 24),
            if (_selectedOffering == 'Providing Service') ...[
              _buildInputField(
                "Professional Title",
                "e.g. Makeup Artist",
                maxLines: 1,
                controller: _professionalTitleController,
              ),
              const SizedBox(height: 24),
              const Text(
                "Service List",
                style: TextStyle(color: Color(0xFF777F84), fontSize: 14),
              ),
              const SizedBox(height: 8),
              ServiceListEditor(items: _services),
              const SizedBox(height: 24),
            ],
            _buildInputField(
              "Business Description", 
              "Share Short description of your business", 
              maxLines: 3,
              helperText: "100 characters required",
            ),
            const SizedBox(height: 24),
            _buildInputField("Product List", "List your products here", maxLines: 3),
            
            const SizedBox(height: 32),
            _buildUploadSection(
              "Business & NAFDAC Certificates", 
              "High resolution image\nPDF, JPG, PNG formats",
              "200 x 200px\n20kb max",
            ),
            const SizedBox(height: 24),
            _buildUploadSection(
              "Business logo", 
              "High resolution image\nPNG formats",
              "200 x 200px\nMust be in Black",
            ),
            
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 32),
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
            color: isActive ? const Color(0xFF603814) : const Color(0xFF777F84),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        )
      ],
    );
  }


  Widget _buildOfferingOption(String title, IconData icon) {
    final isSelected = _selectedOffering == title;
    return InkWell(
      onTap: () => setState(() => _selectedOffering = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFFA15E22) : const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
                 color: isSelected ? const Color(0xFFA15E22) : const Color(0xFF777F84), size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF241508))),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(String title, String leftHint, String rightHint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF89858A), style: BorderStyle.solid), // In real code, use DottedBorder
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: Color(0xFF603814), size: 32),
              const SizedBox(height: 8),
              const Text("Browse Document", style: TextStyle(fontSize: 16, color: Color(0xFF1E2021))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leftHint, style: const TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                    Text(rightHint, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF777F84))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1, String? helperText, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
          ),
        ),
        if (helperText != null) Align(alignment: Alignment.centerRight, child: Text(helperText, style: const TextStyle(fontSize: 10, color: Color(0xFF595F63)))),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(8)),
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

  Widget _buildSubmitButton() {
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
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Make Payment",
            style: TextStyle(
              color: Color(0xFFFFFBF5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}