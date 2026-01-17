import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';

import '../../../../../../../app/router/app_router.dart';
import '../classes_offered_editor.dart';
import '../draft_utils.dart';

class SchoolBusinessDetailsScreen extends StatefulWidget {
  const SchoolBusinessDetailsScreen({super.key});

  @override
  State<SchoolBusinessDetailsScreen> createState() =>
      _SchoolBusinessDetailsScreenState();
}

class _SchoolBusinessDetailsScreenState
    extends State<SchoolBusinessDetailsScreen> {
  String _selectedSchoolType = "Fashion";

  final _schoolNameController = TextEditingController();
  final _schoolBiographyController = TextEditingController();
  final List<ClassOfferedItem> _classes = [ClassOfferedItem()];

  String? _businessLogoPath;
  String? _recognitionCertificatePath;

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolBiographyController.dispose();
    super.dispose();
  }

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

            _buildInputField(
              "School Name",
              "Enter school name",
              controller: _schoolNameController,
            ),
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
              controller: _schoolBiographyController,
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

            const SizedBox(height: 24),
            _buildUploadSection(
              title: 'Business certificate / recognition',
              selectedPath: _recognitionCertificatePath,
              onTap: () async {
                final path = await pickSingleFilePath();
                if (path != null)
                  setState(() => _recognitionCertificatePath = path);
              },
            ),
            const SizedBox(height: 24),
            _buildUploadSection(
              title: 'Business logo',
              selectedPath: _businessLogoPath,
              onTap: () async {
                final path = await pickSingleFilePath();
                if (path != null) setState(() => _businessLogoPath = path);
              },
            ),

            const SizedBox(height: 40),
            _buildContinueButton(context),
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

  Widget _buildStep(
    IconData? icon,
    String label,
    bool isActive, {
    String? stepNumber,
  }) {
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
                : Text(
                    stepNumber ?? "",
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF777F84),
                      fontSize: 10,
                    ),
                  ),
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
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : const Color(0xFF777F84),
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
                  color: isSelected
                      ? const Color(0xFFA15E22)
                      : const Color(0xFF777F84),
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

  Widget _buildUploadSection({
    required String title,
    required String? selectedPath,
    required VoidCallback onTap,
  }) {
    final hasFile = selectedPath != null && selectedPath.isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF777F84), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: hasFile
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF89858A),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 24,
                  color: hasFile
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF777F84),
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile ? 'Document selected' : 'Browse Document',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E2021),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'PDF, JPG, PNG formats',
                  style: TextStyle(fontSize: 10, color: Color(0xFF777F84)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    int maxLines = 1,
    String? helperText,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777F84), fontSize: 14),
        ),
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
              child: Text(
                helperText,
                style: const TextStyle(fontSize: 10, color: Color(0xFF595F63)),
              ),
            ),
          ),
      ],
    );
  }

  bool _validateForm() {
    final name = _schoolNameController.text.trim();
    final bio = _schoolBiographyController.text.trim();
    final hasCert =
        _recognitionCertificatePath != null &&
        _recognitionCertificatePath!.isNotEmpty;
    final hasLogo = _businessLogoPath != null && _businessLogoPath!.isNotEmpty;

    if (name.isEmpty) {
      AppSnackbars.showError(context, 'Please enter your school name');
      return false;
    }

    if (bio.isEmpty) {
      AppSnackbars.showError(context, 'Please enter your school biography');
      return false;
    }

    if (bio.length < 100) {
      AppSnackbars.showError(
        context,
        'School biography must be at least 100 characters',
      );
      return false;
    }

    final validClasses = _classes
        .where((c) => c.name.trim().isNotEmpty)
        .toList();
    if (validClasses.isEmpty) {
      AppSnackbars.showError(context, 'Please add at least one class offered');
      return false;
    }

    if (!hasCert) {
      AppSnackbars.showError(
        context,
        'Please upload a certificate / recognition document',
      );
      return false;
    }

    if (!hasLogo) {
      AppSnackbars.showError(context, 'Please upload your business logo');
      return false;
    }

    return true;
  }

  Widget _buildContinueButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!_validateForm()) return;

        final draft = draftFromArgs(
          ModalRoute.of(context)?.settings.arguments,
          categoryLabelFallback: 'Schools',
        );
        final updated = draft
          ..businessName = _schoolNameController.text.trim()
          ..businessDescription = _schoolBiographyController.text.trim()
          ..schoolType = _selectedSchoolType.toLowerCase()
          ..schoolBiography = _schoolBiographyController.text.trim()
          ..classesOffered = _classes
          ..businessLogoPath = _businessLogoPath
          ..businessCertificates = _recognitionCertificatePath != null
              ? [
                  {
                    'path': _recognitionCertificatePath,
                    'name': 'Certificate / Recognition',
                  },
                ]
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
              color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
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
