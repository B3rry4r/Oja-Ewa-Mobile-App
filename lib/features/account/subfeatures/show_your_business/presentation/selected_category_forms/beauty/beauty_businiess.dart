import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';

import '../../../../../../../app/router/app_router.dart';
import '../service_list_editor.dart';
import '../draft_utils.dart';

class BeautyBusinessDetailsScreen extends StatefulWidget {
  const BeautyBusinessDetailsScreen({super.key});

  @override
  State<BeautyBusinessDetailsScreen> createState() =>
      _BeautyBusinessDetailsScreenState();
}

class _BeautyBusinessDetailsScreenState
    extends State<BeautyBusinessDetailsScreen> {
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();

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
          _buildStepperHeader(),
          const SizedBox(height: 32),
          Text(
            "About Business",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            "Business Name",
            "Enter business name",
            controller: _businessNameController,
          ),
          const SizedBox(height: 24),

          // Professional Title (for service providers)
          _buildInputField(
            "Professional Title",
            "e.g. Makeup Artist, Hair Stylist",
            maxLines: 1,
            controller: _professionalTitleController,
          ),
          const SizedBox(height: 24),

          // Service List
          Text(
            "Service List",
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ServiceListEditor(items: _services),
          const SizedBox(height: 24),

          _buildInputField(
            "Business Description",
            "Share Short description of your business",
            maxLines: 3,
            helperText: "100 characters required",
            controller: _businessDescriptionController,
          ),

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
    );
  }

  Widget _buildStepperHeader() {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(colors, Icons.check, "Basic\nInfo", true),
        _buildStep(colors, null, "Business\nDetails", true, stepNumber: "2"),
        _buildStep(colors, null, "Account\non review", false, stepNumber: "3"),
      ],
    );
  }

  Widget _buildStep(
    AppThemeColors colors,
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
            color: isActive ? colors.accent : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: colors.onAccent, size: 16)
                : Text(
                    stepNumber ?? "",
                    style: TextStyle(
                      color: isActive ? colors.onAccent : colors.textTertiary,
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
            color: isActive ? colors.textPrimary : colors.textTertiary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String leftHint,
    required String rightHint,
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
              color: colors.surfaceElevated,
              border: Border.all(
                color: hasFile ? const Color(0xFF4CAF50) : colors.border,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  color: hasFile ? const Color(0xFF4CAF50) : colors.accent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  hasFile ? "File selected" : "Browse Document",
                  style: TextStyle(
                    fontSize: 16,
                    color: hasFile
                        ? const Color(0xFF4CAF50)
                        : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leftHint,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textTertiary,
                        ),
                      ),
                      Text(
                        rightHint,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textTertiary,
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
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontFamily: 'Campton',
              fontSize: 16,
              color: colors.textPrimary,
            ),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (helperText != null)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              helperText,
              style: TextStyle(fontSize: 10, color: colors.textTertiary),
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

    // Afro Beauty businesses only provide services
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

    if (_businessLogoPath == null) {
      AppSnackbars.showError(context, 'Please upload your business logo');
      return false;
    }

    return true;
  }

  Widget _buildSubmitButton() {
    final colors = context.appColors;
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
          ..offeringType =
              'providing_service' // Afro Beauty only provides services
          ..productList =
              const [] // Products handled via seller flow
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
