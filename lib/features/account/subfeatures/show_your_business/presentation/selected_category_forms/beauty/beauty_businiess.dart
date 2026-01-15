import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';

import '../../../../../../../app/router/app_router.dart';
import '../service_list_editor.dart';
import '../product_list_editor.dart';
import '../draft_utils.dart';

class BeautyBusinessDetailsScreen extends StatefulWidget {
  const BeautyBusinessDetailsScreen({super.key});

  @override
  State<BeautyBusinessDetailsScreen> createState() => _BeautyBusinessDetailsScreenState();
}

class _BeautyBusinessDetailsScreenState extends State<BeautyBusinessDetailsScreen> {
  String _selectedOffering = "Selling Product";

  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final List<String> _products = [''];

  final TextEditingController _professionalTitleController = TextEditingController();
  final List<ServiceListItem> _services = [ServiceListItem()];

  // File upload paths
  String? _businessCertificatePath;
  String? _businessLogoPath;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
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
            _buildInputField("Business Name", "Enter business name", controller: _businessNameController),
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
              controller: _businessDescriptionController,
            ),
            
            if (_selectedOffering == 'Selling Product') ...[
              const SizedBox(height: 24),
              const Text(
                "What do you sell?",
                style: TextStyle(color: Color(0xFF777F84), fontSize: 14),
              ),
              const SizedBox(height: 8),
              ProductListEditor(items: _products),
            ],
            
            const SizedBox(height: 32),
            _buildUploadSection(
              title: "Business Certificate", 
              leftHint: "High resolution image\nPDF, JPG, PNG formats",
              rightHint: "200 x 200px\n20kb max",
              selectedPath: _businessCertificatePath,
              onTap: () async {
                final path = await pickSingleFilePath();
                if (path != null) setState(() => _businessCertificatePath = path);
              },
            ),
            const SizedBox(height: 24),
            _buildUploadSection(
              title: "Business logo", 
              leftHint: "High resolution image\nPNG formats",
              rightHint: "200 x 200px\nMust be in Black",
              selectedPath: _businessLogoPath,
              onTap: () async {
                final path = await pickSingleFilePath();
                if (path != null) setState(() => _businessLogoPath = path);
              },
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

  Widget _buildUploadSection({
    required String title,
    required String leftHint,
    required String rightHint,
    required String? selectedPath,
    required VoidCallback onTap,
  }) {
    final hasFile = selectedPath != null && selectedPath.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              border: Border.all(color: hasFile ? const Color(0xFF4CAF50) : const Color(0xFF89858A)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  color: hasFile ? const Color(0xFF4CAF50) : const Color(0xFF603814),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  hasFile ? "File selected" : "Browse Document",
                  style: TextStyle(
                    fontSize: 16,
                    color: hasFile ? const Color(0xFF4CAF50) : const Color(0xFF1E2021),
                  ),
                ),
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

  bool _validateForm() {
    final businessName = _businessNameController.text.trim();
    final businessDescription = _businessDescriptionController.text.trim();
    
    if (businessName.isEmpty) {
      AppSnackbars.showError(context, 'Please enter your business name');
      return false;
    }
    
    if (businessDescription.isEmpty) {
      AppSnackbars.showError(context, 'Please enter your business description');
      return false;
    }
    
    if (businessDescription.length < 100) {
      AppSnackbars.showError(context, 'Business description must be at least 100 characters');
      return false;
    }
    
    if (_selectedOffering == 'Selling Product') {
      final validProducts = _products.where((p) => p.trim().isNotEmpty).toList();
      if (validProducts.isEmpty) {
        AppSnackbars.showError(context, 'Please add at least one product');
        return false;
      }
    }
    
    if (_selectedOffering == 'Providing Service') {
      final professionalTitle = _professionalTitleController.text.trim();
      if (professionalTitle.isEmpty) {
        AppSnackbars.showError(context, 'Please enter your professional title');
        return false;
      }
      final validServices = _services.where((s) => s.name.trim().isNotEmpty).toList();
      if (validServices.isEmpty) {
        AppSnackbars.showError(context, 'Please add at least one service');
        return false;
      }
    }
    
    if (_businessLogoPath == null) {
      AppSnackbars.showError(context, 'Please upload your business logo');
      return false;
    }
    
    return true;
  }

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: () {
        if (!_validateForm()) return;
        
        final draft = draftFromArgs(
            ModalRoute.of(context)?.settings.arguments,
            categoryLabelFallback: 'Beauty',
          );
          final updated = draft
            ..businessName = _businessNameController.text.trim()
            ..businessDescription = _businessDescriptionController.text.trim()
            ..offeringType = mapOfferingLabelToEnum(_selectedOffering)
            ..productList = _products.where((p) => p.trim().isNotEmpty).toList()
            ..professionalTitle = _professionalTitleController.text.trim()
            ..serviceList = _services
            ..businessLogoPath = _businessLogoPath
            ..businessCertificates = _businessCertificatePath != null 
                ? [{'path': _businessCertificatePath, 'name': 'Business Certificate'}] 
                : null;

          Navigator.of(context).pushNamed(
            AppRoutes.businessAccountReview,
            arguments: updated.toJson(),
          );
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
              color: const Color(0xFFFDAF40).withAlpha(102),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}