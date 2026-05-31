import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/subfeatures/shared/widgets/compliance_progress_banner.dart';

import 'package:ojaewa/core/location/location_picker_sheets.dart';
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
  String _selectedSchoolType = 'Fashion';

  final _schoolNameController = TextEditingController();
  final _schoolBiographyController = TextEditingController();
  final _owner1NameController = TextEditingController();
  final _owner1PercentageController = TextEditingController();
  final _owner1NationalityController = TextEditingController();
  final _owner1IdController = TextEditingController();
  final _owner2NameController = TextEditingController();
  final _owner2PercentageController = TextEditingController();
  final _owner2NationalityController = TextEditingController();
  final _owner2IdController = TextEditingController();
  final _owner3NameController = TextEditingController();
  final _owner3PercentageController = TextEditingController();
  final _owner3NationalityController = TextEditingController();
  final _owner3IdController = TextEditingController();
  final _printedNameController = TextEditingController();
  final _submissionDateController = TextEditingController();

  final List<ClassOfferedItem> _classes = [ClassOfferedItem()];

  String _preferredSettlementCurrency = 'NGN';
  bool _declarationLegalRegistered = false;
  bool _declarationInformationTrue = false;
  bool _declarationAuthorizeVerification = false;
  bool _authorizeSettlementAccount = false;
  bool _acceptPartnerBankTerms = false;
  String? _businessLogoPath;
  String? _recognitionCertificatePath;
  String? _signaturePath;

  static const _sections = [
    'Business Information',
    'Business Type & Industry',
    'Registered Office',
    'Authorized Signatory',
    'Beneficial Owners',
    'Banking & Settlement',
    'Declarations',
    'Signature',
  ];

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolBiographyController.dispose();
    _owner1NameController.dispose();
    _owner1PercentageController.dispose();
    _owner1NationalityController.dispose();
    _owner1IdController.dispose();
    _owner2NameController.dispose();
    _owner2PercentageController.dispose();
    _owner2NationalityController.dispose();
    _owner2IdController.dispose();
    _owner3NameController.dispose();
    _owner3PercentageController.dispose();
    _owner3NationalityController.dispose();
    _owner3IdController.dispose();
    _printedNameController.dispose();
    _submissionDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = draftFromArgs(
      ModalRoute.of(context)?.settings.arguments,
      categoryLabelFallback: 'Schools',
    );
    _schoolNameController.text = _schoolNameController.text.isEmpty
        ? (draft.businessName ?? '')
        : _schoolNameController.text;
    _schoolBiographyController.text = _schoolBiographyController.text.isEmpty
        ? (draft.schoolBiography ?? draft.businessDescription ?? '')
        : _schoolBiographyController.text;
    _selectedSchoolType = draft.schoolType != null
        ? _capitalize(draft.schoolType!)
        : _selectedSchoolType;
    _businessLogoPath = _businessLogoPath ?? draft.businessLogoPath;
    _signaturePath = _signaturePath ?? draft.authorizedSignatorySignaturePath;
    _printedNameController.text = _printedNameController.text.isEmpty
        ? (draft.printedNameOfAuthorizedSignatory ?? '')
        : _printedNameController.text;
    _submissionDateController.text = _submissionDateController.text.isEmpty
        ? (draft.submissionDate ?? '')
        : _submissionDateController.text;
    _preferredSettlementCurrency =
        draft.preferredSettlementCurrency ?? _preferredSettlementCurrency;
    _declarationLegalRegistered =
        draft.declarationLegalRegistered ?? _declarationLegalRegistered;
    _declarationInformationTrue =
        draft.declarationInformationTrue ?? _declarationInformationTrue;
    _declarationAuthorizeVerification =
        draft.declarationAuthorizeVerification ??
        _declarationAuthorizeVerification;
    _authorizeSettlementAccount =
        draft.authorizeSettlementAccount ?? _authorizeSettlementAccount;
    _acceptPartnerBankTerms =
        draft.acceptPartnerBankTerms ?? _acceptPartnerBankTerms;
    final owners = draft.beneficialOwners ?? const [];
    if (owners.isNotEmpty) _fillOwner(owners[0], 1);
    if (owners.length > 1) _fillOwner(owners[1], 2);
    if (owners.length > 2) _fillOwner(owners[2], 3);
    if (_recognitionCertificatePath == null &&
        (draft.businessCertificates ?? []).isNotEmpty) {
      final first = draft.businessCertificates!.first;
      _recognitionCertificatePath = first['path']?.toString();
    }

    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const ComplianceProgressBanner(
            title: 'Business compliance onboarding',
            subtitle:
                'Finish your school profile details, beneficial owners, declarations, and signature before final review.',
            currentSection: 'Beneficial Owners',
            sectionLabels: _sections,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('School Profile Details'),
          const SizedBox(height: 16),
          _buildInputField(
            'School Name',
            'Enter school name',
            controller: _schoolNameController,
          ),
          const SizedBox(height: 24),
          Text(
            'School Type',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildSchoolTypeGrid(),
          const SizedBox(height: 24),
          _buildInputField(
            'School Biography',
            'Share a full business profile description',
            maxLines: 4,
            controller: _schoolBiographyController,
          ),
          const SizedBox(height: 24),
          Text(
            'Classes offered',
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ClassesOfferedEditor(items: _classes),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 5: Beneficial Owners'),
          const SizedBox(height: 16),
          _buildOwnerCard(1),
          const SizedBox(height: 16),
          _buildOwnerCard(2),
          const SizedBox(height: 16),
          _buildOwnerCard(3),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 6: Banking & Settlement Preferences'),
          const SizedBox(height: 16),
          _buildCurrencyDropdown(),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 7: Compliance & Declarations'),
          const SizedBox(height: 16),
          _buildCheckTile(
            value: _declarationLegalRegistered,
            label:
                'I confirm the business is legally registered and operating.',
            onChanged: (value) =>
                setState(() => _declarationLegalRegistered = value),
          ),
          _buildCheckTile(
            value: _declarationInformationTrue,
            label: 'The information provided is true and complete.',
            onChanged: (value) =>
                setState(() => _declarationInformationTrue = value),
          ),
          _buildCheckTile(
            value: _declarationAuthorizeVerification,
            label:
                'I authorize Ojaewa to verify this information with third parties.',
            onChanged: (value) =>
                setState(() => _declarationAuthorizeVerification = value),
          ),
          _buildCheckTile(
            value: _authorizeSettlementAccount,
            label: 'I authorize Ojaewa to open a settlement account for me.',
            onChanged: (value) =>
                setState(() => _authorizeSettlementAccount = value),
          ),
          _buildCheckTile(
            value: _acceptPartnerBankTerms,
            label:
                'I accept Ojaewa partner bank terms of service and corporate account agreement.',
            onChanged: (value) =>
                setState(() => _acceptPartnerBankTerms = value),
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 8: Submission & Signature'),
          const SizedBox(height: 16),
          _buildInputField(
            'Printed Name of Authorized Signatory',
            'Kemi James',
            controller: _printedNameController,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Submission Date',
            'Select date',
            controller: _submissionDateController,
            readOnly: true,
            onTap: _pickSubmissionDate,
          ),
          const SizedBox(height: 24),
          _buildUploadSection(
            title: 'Business certificate / recognition',
            selectedPath: _recognitionCertificatePath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) {
                setState(() => _recognitionCertificatePath = path);
              }
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
          const SizedBox(height: 24),
          _buildUploadSection(
            title: 'Authorized signatory signature',
            selectedPath: _signaturePath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) setState(() => _signaturePath = path);
            },
          ),
          const SizedBox(height: 40),
          _buildContinueButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _fillOwner(Map<String, dynamic> owner, int index) {
    final (name, percentage, nationality, id) = _controllersForOwner(index);
    name.text = (owner['full_name'] as String?) ?? '';
    percentage.text = owner['ownership_percentage']?.toString() ?? '';
    nationality.text = (owner['nationality'] as String?) ?? '';
    id.text = (owner['id_type_and_number'] as String?) ?? '';
  }

  (
    TextEditingController,
    TextEditingController,
    TextEditingController,
    TextEditingController,
  )
  _controllersForOwner(int index) {
    switch (index) {
      case 1:
        return (
          _owner1NameController,
          _owner1PercentageController,
          _owner1NationalityController,
          _owner1IdController,
        );
      case 2:
        return (
          _owner2NameController,
          _owner2PercentageController,
          _owner2NationalityController,
          _owner2IdController,
        );
      default:
        return (
          _owner3NameController,
          _owner3PercentageController,
          _owner3NationalityController,
          _owner3IdController,
        );
    }
  }

  List<Map<String, dynamic>> _beneficialOwners() {
    final owners = <Map<String, dynamic>>[];
    for (var i = 1; i <= 3; i++) {
      final (name, percentage, nationality, id) = _controllersForOwner(i);
      final n = name.text.trim();
      final p = percentage.text.trim();
      final nat = nationality.text.trim();
      final doc = id.text.trim();
      if (n.isEmpty && p.isEmpty && nat.isEmpty && doc.isEmpty) continue;
      owners.add({
        'full_name': n,
        'ownership_percentage': num.tryParse(p) ?? 0,
        'nationality': nat,
        'id_type_and_number': doc,
      });
    }
    return owners;
  }

  Widget _buildSectionHeader(String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildSchoolTypeGrid() {
    final colors = context.appColors;
    final types = ['Fashion', 'Music', 'Catering', 'Beauty'];
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
              color: isSelected ? colors.accent.withValues(alpha: 0.08) : null,
              border: Border.all(
                color: isSelected ? colors.accent : colors.textSecondary,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 18,
                  color: isSelected ? colors.accent : colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
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

  Widget _buildOwnerCard(int index) {
    final (name, percentage, nationality, id) = _controllersForOwner(index);
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner $index',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputField('Full Name', 'Kemi James', controller: name),
          const SizedBox(height: 12),
          _buildInputField(
            'Ownership % (max 100)',
            '70',
            controller: percentage,
            keyboardType: TextInputType.number,
            maxLength: 3,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PercentageInputFormatter(),
            ],
          ),
          const SizedBox(height: 12),
          _buildLocationDropdown(
            label: 'Nationality',
            value: nationality.text.isEmpty ? 'Select Country' : nationality.text,
            onTap: () async {
              final country = await CountryPickerSheet.show(
                context,
                selectedCountry: nationality.text,
              );
              if (country != null && mounted) {
                setState(() => nationality.text = country.name);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'NIN (11 digits)',
            '12345678901',
            controller: id,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _preferredSettlementCurrency,
          isExpanded: true,
          dropdownColor: colors.surface,
          style: TextStyle(color: colors.textPrimary, fontSize: 16),
          items: const ['USD', 'EUR', 'GBP', 'NGN']
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _preferredSettlementCurrency = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.appColors;
    return CheckboxListTile(
      value: value,
      contentPadding: EdgeInsets.zero,
      activeColor: colors.accent,
      checkColor: colors.onAccent,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        label,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
      ),
      onChanged: (next) => onChanged(next ?? false),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String? selectedPath,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    final hasFile = selectedPath != null && selectedPath.isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: hasFile ? const Color(0xFF4CAF50) : colors.borderStrong,
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
                      : colors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile ? 'Document selected' : 'Browse Document',
                  style: TextStyle(fontSize: 16, color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF, JPG, PNG formats',
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
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
    int? maxLength,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
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
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 16,
            color: colors.textPrimary,
          ),
          maxLines: maxLines,
          decoration: InputDecoration(
            counterText: maxLength != null ? null : '',
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.all(16),
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

  Future<void> _pickSubmissionDate() async {
    final initial =
        DateTime.tryParse(_submissionDateController.text.trim()) ??
        DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final year = picked.year.toString().padLeft(4, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      _submissionDateController.text = '$year-$month-$day';
    });
  }

  bool _validateForm() {
    final name = _schoolNameController.text.trim();
    final bio = _schoolBiographyController.text.trim();
    if (name.isEmpty) {
      AppSnackbars.showError(context, 'Please enter your school name');
      return false;
    }
    if (bio.isEmpty || bio.length < 50) {
      AppSnackbars.showError(
        context,
        'School biography must be at least 50 characters',
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
    if (_beneficialOwners().isEmpty) {
      AppSnackbars.showError(context, 'Add at least one beneficial owner');
      return false;
    }
    if ((_recognitionCertificatePath ?? '').isEmpty ||
        (_businessLogoPath ?? '').isEmpty ||
        (_signaturePath ?? '').isEmpty) {
      AppSnackbars.showError(
        context,
        'Upload the required business certificate, logo, and signature',
      );
      return false;
    }
    if (_printedNameController.text.trim().isEmpty ||
        _submissionDateController.text.trim().isEmpty) {
      AppSnackbars.showError(
        context,
        'Complete printed signatory name and submission date',
      );
      return false;
    }
    if (!_declarationLegalRegistered ||
        !_declarationInformationTrue ||
        !_declarationAuthorizeVerification ||
        !_authorizeSettlementAccount ||
        !_acceptPartnerBankTerms) {
      AppSnackbars.showError(context, 'All declarations must be accepted');
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
          ..beneficialOwners = _beneficialOwners()
          ..preferredSettlementCurrency = _preferredSettlementCurrency
          ..declarationLegalRegistered = _declarationLegalRegistered
          ..declarationInformationTrue = _declarationInformationTrue
          ..declarationAuthorizeVerification = _declarationAuthorizeVerification
          ..authorizeSettlementAccount = _authorizeSettlementAccount
          ..acceptPartnerBankTerms = _acceptPartnerBankTerms
          ..printedNameOfAuthorizedSignatory = _printedNameController.text
              .trim()
          ..authorizedSignatorySignaturePath = _signaturePath
          ..submissionDate = _submissionDateController.text.trim()
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
            'Continue',
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

  Widget _buildLocationDropdown({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 13, )),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value == 'Select Country' ? colors.textTertiary : colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    if (n.text.isEmpty) return n;
    final val = int.tryParse(n.text);
    if (val == null || val > 100) return o;
    return n;
  }
}
