import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';

import '../../../../../../../app/router/app_router.dart';
import '../service_list_editor.dart';
import '../product_list_editor.dart';
import '../draft_utils.dart';

class BrandBusinessDetailsScreen extends StatefulWidget {
  const BrandBusinessDetailsScreen({super.key});

  @override
  State<BrandBusinessDetailsScreen> createState() =>
      _BrandBusinessDetailsScreenState();
}

class _BrandBusinessDetailsScreenState
    extends State<BrandBusinessDetailsScreen> {
  String _selectedOffering = 'Selling Product';

  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final List<String> _products = [''];
  final TextEditingController _professionalTitleController =
      TextEditingController();
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
    final colors = context.appColors;
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildProgressStepper(),
          const SizedBox(height: 32),

          // About Business Header
          Text(
            "About Business",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Form Fields
          _buildInputField(
            "Business Name",
            "Enter business name",
            controller: _businessNameController,
          ),
          const SizedBox(height: 24),
          _buildInputField(
            "Business Description",
            "Share short description of your business",
            maxLines: 4,
            helperText: "100 characters required",
            controller: _businessDescriptionController,
          ),
          const SizedBox(height: 24),

          // Offering type
          Text(
            "Select type of offering",
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildOfferingOption("Selling Product", Icons.shopping_bag_outlined),
          const SizedBox(height: 8),
          _buildOfferingOption(
            "Providing Service",
            Icons.build_circle_outlined,
          ),
          const SizedBox(height: 24),

          if (_selectedOffering == 'Providing Service') ...[
            _buildInputField(
              "Professional Title",
              "e.g. Fashion Designer",
              controller: _professionalTitleController,
            ),
            const SizedBox(height: 24),
            Text(
              "Service List",
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ServiceListEditor(items: _services),
            const SizedBox(height: 24),
          ] else ...[
            Text(
              "What do you sell?",
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ProductListEditor(items: _products),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 32),

          // Upload Sections
          _buildUploadCard(
            title: "Business Certificate",
            hintLeft: "High resolution image\nPDF, JPEG, PNG formats",
            hintRight: "200 x 200px\n20kb Max",
            selectedPath: _businessCertificatePath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) {
                setState(() => _businessCertificatePath = path);
              }
            },
          ),
          const SizedBox(height: 24),
          _buildUploadCard(
            title: "Business logo",
            hintLeft: "High resolution image\nPNG formats",
            hintRight: "200 x 200px\nMust be in Black",
            selectedPath: _businessLogoPath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) setState(() => _businessLogoPath = path);
            },
          ),

          const SizedBox(height: 40),
          _buildSubmitButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(Icons.check, "Basic\nInfo", true, isCompleted: true),
        _buildStep(null, "Business\nDetails", true, stepNum: "2"),
        _buildStep(null, "Account\non review", false, stepNum: "3"),
      ],
    );
  }

  Widget _buildStep(
    IconData? icon,
    String label,
    bool isActive, {
    bool isCompleted = false,
    String? stepNum,
  }) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? colors.textPrimary : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: colors.background, size: 16)
                : Text(
                    stepNum ?? "",
                    style: TextStyle(
                      color: isActive
                          ? colors.background
                          : colors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
            color: isActive ? colors.textPrimary : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    int maxLines = 1,
    String? helperText,
    TextEditingController? controller,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 16,
            color: colors.textPrimary,
          ),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary, fontSize: 16),
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
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              helperText,
              style: TextStyle(color: colors.textTertiary, fontSize: 10),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOfferingOption(String title, IconData icon) {
    final colors = context.appColors;
    final isSelected = _selectedOffering == title;
    return InkWell(
      onTap: () => setState(() => _selectedOffering = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.08) : null,
          border: Border.all(color: isSelected ? colors.accent : colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? colors.accent : colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String hintLeft,
    required String hintRight,
    required String? selectedPath,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    final hasFile = selectedPath != null && selectedPath.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: hasFile ? const Color(0xFF4CAF50) : colors.borderStrong,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  color: hasFile ? const Color(0xFF4CAF50) : colors.textPrimary,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  hasFile ? "File selected" : "Browse Document",
                  style: TextStyle(
                    fontSize: 16,
                    color: hasFile
                        ? const Color(0xFF4CAF50)
                        : colors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hintLeft,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        hintRight,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
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
      AppSnackbars.showError(
        context,
        'Business description must be at least 100 characters',
      );
      return false;
    }

    if (_selectedOffering == 'Selling Product') {
      final validProducts = _products
          .where((p) => p.trim().isNotEmpty)
          .toList();
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
      final validServices = _services
          .where((s) => s.name.trim().isNotEmpty)
          .toList();
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

  Widget _buildSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!_validateForm()) return;

        final draft = draftFromArgs(
          ModalRoute.of(context)?.settings.arguments,
          categoryLabelFallback: 'Brands',
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
              ? [
                  {
                    'path': _businessCertificatePath,
                    'name': 'Business Certificate',
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
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111111).withValues(alpha: 0.4),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
