import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/account/subfeatures/shared/widgets/compliance_progress_banner.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';

import '../../../../../../app/router/app_router.dart';
import 'business_registration_draft.dart';

class BusinessSellerRegistrationScreen extends ConsumerStatefulWidget {
  const BusinessSellerRegistrationScreen({super.key});

  @override
  ConsumerState<BusinessSellerRegistrationScreen> createState() =>
      _BusinessSellerRegistrationScreenState();
}

class _BusinessSellerRegistrationScreenState
    extends ConsumerState<BusinessSellerRegistrationScreen> {
  final _businessNameController = TextEditingController();
  final _legalBusinessNameController = TextEditingController();
  final _tradingNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _tinController = TextEditingController();
  final _identityValueController = TextEditingController();
  final _dateOfIncorporationController = TextEditingController();
  final _countryOfIncorporationController = TextEditingController();
  final _industryController = TextEditingController();
  final _employeesController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _signatoryNameController = TextEditingController();
  final _signatoryJobTitleController = TextEditingController();
  final _signatoryEmailController = TextEditingController();
  final _signatoryPhoneController = TextEditingController();
  final _signatoryIdController = TextEditingController();
  final _signatoryDobController = TextEditingController();

  String _selectedCountryName = '';
  String _selectedCountryFlag = '';
  String _selectedStateName = '';
  String _businessType = 'limited_liability_company';
  String _turnoverRange = '50000_to_250000';
  String _otherBusinessType = '';
  String _identityType = 'nin';
  String? _identityDocumentLocalPath;

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
  static const _industryOptions = [
    'Retail',
    'Technology',
    'Logistics',
    'Education',
    'Manufacturing',
    'Fashion',
    'Beauty',
    'Agriculture',
    'Healthcare',
    'Creative',
    'Other',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _legalBusinessNameController.dispose();
    _tradingNameController.dispose();
    _registrationNumberController.dispose();
    _tinController.dispose();
    _identityValueController.dispose();
    _dateOfIncorporationController.dispose();
    _countryOfIncorporationController.dispose();
    _industryController.dispose();
    _employeesController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _signatoryNameController.dispose();
    _signatoryJobTitleController.dispose();
    _signatoryEmailController.dispose();
    _signatoryPhoneController.dispose();
    _signatoryIdController.dispose();
    _signatoryDobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final draftFromArgs = args is Map<String, dynamic>
        ? BusinessRegistrationDraft.fromJson(args)
        : null;
    final selectedCategory =
        draftFromArgs?.categoryLabel ?? (args as String?) ?? 'Schools';

    _businessNameController.text = _businessNameController.text.isEmpty
        ? (draftFromArgs?.businessName ?? '')
        : _businessNameController.text;
    _legalBusinessNameController.text =
        _legalBusinessNameController.text.isEmpty
        ? (draftFromArgs?.legalBusinessName ?? '')
        : _legalBusinessNameController.text;
    _tradingNameController.text = _tradingNameController.text.isEmpty
        ? (draftFromArgs?.tradingName ?? '')
        : _tradingNameController.text;
    _registrationNumberController.text =
        _registrationNumberController.text.isEmpty
        ? (draftFromArgs?.businessRegistrationNumber ?? '')
        : _registrationNumberController.text;
    _tinController.text = _tinController.text.isEmpty
        ? (draftFromArgs?.taxIdentificationNumber ?? '')
        : _tinController.text;
    _identityType = ((draftFromArgs?.bvn ?? '').trim().isNotEmpty)
        ? 'bvn'
        : _identityType;
    _identityValueController.text = _identityValueController.text.isEmpty
        ? (_identityType == 'bvn'
              ? (draftFromArgs?.bvn ?? '')
              : (draftFromArgs?.nin ?? ''))
        : _identityValueController.text;
    _dateOfIncorporationController.text =
        _dateOfIncorporationController.text.isEmpty
        ? (draftFromArgs?.dateOfIncorporation ?? '')
        : _dateOfIncorporationController.text;
    _countryOfIncorporationController.text =
        _countryOfIncorporationController.text.isEmpty
        ? (draftFromArgs?.countryOfIncorporation ?? '')
        : _countryOfIncorporationController.text;
    _industryController.text = _industryController.text.isEmpty
        ? (draftFromArgs?.industrySector ?? '')
        : _industryController.text;
    _employeesController.text = _employeesController.text.isEmpty
        ? (draftFromArgs?.numberOfEmployees?.toString() ?? '')
        : _employeesController.text;
    _websiteController.text = _websiteController.text.isEmpty
        ? (draftFromArgs?.website ?? '')
        : _websiteController.text;
    _emailController.text = _emailController.text.isEmpty
        ? (draftFromArgs?.businessEmail ?? '')
        : _emailController.text;
    _phoneController.text = _phoneController.text.isEmpty
        ? (draftFromArgs?.businessPhoneNumber ?? '')
        : _phoneController.text;
    _cityController.text = _cityController.text.isEmpty
        ? (draftFromArgs?.city ?? '')
        : _cityController.text;
    _addressController.text = _addressController.text.isEmpty
        ? (draftFromArgs?.address ?? '')
        : _addressController.text;
    _postalCodeController.text = _postalCodeController.text.isEmpty
        ? (draftFromArgs?.postalCode ?? '')
        : _postalCodeController.text;
    _signatoryNameController.text = _signatoryNameController.text.isEmpty
        ? (draftFromArgs?.authorizedSignatoryFullName ?? '')
        : _signatoryNameController.text;
    _signatoryJobTitleController.text =
        _signatoryJobTitleController.text.isEmpty
        ? (draftFromArgs?.authorizedSignatoryJobTitle ?? '')
        : _signatoryJobTitleController.text;
    _signatoryEmailController.text = _signatoryEmailController.text.isEmpty
        ? (draftFromArgs?.authorizedSignatoryEmail ?? '')
        : _signatoryEmailController.text;
    _signatoryPhoneController.text = _signatoryPhoneController.text.isEmpty
        ? (draftFromArgs?.authorizedSignatoryPhoneNumber ?? '')
        : _signatoryPhoneController.text;
    _signatoryIdController.text = _signatoryIdController.text.isEmpty
        ? (draftFromArgs?.authorizedSignatoryIdNumber ?? '')
        : _signatoryIdController.text;
    _signatoryDobController.text = _signatoryDobController.text.isEmpty
        ? (draftFromArgs?.authorizedSignatoryDateOfBirth ?? '')
        : _signatoryDobController.text;
    _selectedCountryName = _selectedCountryName.isEmpty
        ? (draftFromArgs?.country ?? '')
        : _selectedCountryName;
    _selectedStateName = _selectedStateName.isEmpty
        ? (draftFromArgs?.state ?? '')
        : _selectedStateName;
    _businessType = draftFromArgs?.businessType ?? _businessType;
    _turnoverRange = draftFromArgs?.annualTurnoverRange ?? _turnoverRange;
    _otherBusinessType = draftFromArgs?.otherBusinessType ?? _otherBusinessType;
    _identityDocumentLocalPath =
        _identityDocumentLocalPath ?? draftFromArgs?.identityDocumentPath;

    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ComplianceProgressBanner(
            title: (ModalRoute.of(context)?.settings.arguments is Map) ? 'Edit Business Information' : 'Business compliance onboarding',
            subtitle:
                'Start with the legal business profile, registered address, and authorized signatory details.',
            currentSection: 'Business Information',
            sectionLabels: _sections,
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 1: Business Information'),
          const SizedBox(height: 16),
          _buildTextInput(
            'Business Name',
            'Oja Ewa Academy',
            controller: _businessNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Legal Business Name',
            'Oja Ewa Academy Ltd',
            controller: _legalBusinessNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Trading Name',
            'Oja Ewa Academy',
            controller: _tradingNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Business Registration Number (Optional if business name is provided)',
            'RC9876543',
            controller: _registrationNumberController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Tax Identification Number',
            '12345678-0002',
            controller: _tinController,
            maxLength: 14,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Identity Type',
            value: _identityType,
            items: const {'nin': 'NIN', 'bvn': 'BVN'},
            onChanged: (value) => setState(() => _identityType = value),
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            _identityType == 'bvn' ? 'BVN (11 digits)' : 'NIN (11 digits)',
            '12345678901',
            controller: _identityValueController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Date of Incorporation',
            'Select date',
            controller: _dateOfIncorporationController,
            readOnly: true,
            onTap: () => _pickDateInto(_dateOfIncorporationController),
          ),
          const SizedBox(height: 16),
          _buildLocationDropdown(
            label: 'Country of Incorporation',
            value: _countryOfIncorporationController.text.isEmpty
                ? 'Select Country'
                : _countryOfIncorporationController.text,
            onTap: () async {
              final country = await CountryPickerSheet.show(
                context,
                selectedCountry: _countryOfIncorporationController.text,
              );
              if (country != null && mounted) {
                setState(() {
                  _countryOfIncorporationController.text = country.name;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _buildLocationDropdown(
            label: 'State / Province',
            value: _selectedStateName.isEmpty
                ? 'Select State'
                : _selectedStateName,
            onTap: () async {
              if (_selectedCountryName.isEmpty) return;
              final state = await StatePickerSheet.show(
                context,
                countryName: _selectedCountryName,
                selectedState: _selectedStateName,
              );
              if (state != null) {
                setState(() => _selectedStateName = state.name);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'City / Municipality',
            'Lekki',
            controller: _cityController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Street Address',
            '5 Admiralty Way',
            controller: _addressController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Postal / Zip Code',
            '106104',
            controller: _postalCodeController,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 -]'))],
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 4: Authorized Signatory'),
          const SizedBox(height: 16),
          _buildTextInput(
            'Full Name',
            'Kemi James',
            controller: _signatoryNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Job Title',
            'CEO',
            controller: _signatoryJobTitleController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Email Address',
            'kemi@ojaewa.com',
            controller: _signatoryEmailController,
          ),
          const SizedBox(height: 16),
          _buildPhoneInput(
            'Phone Number',
            controller: _signatoryPhoneController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'National ID / Passport Number (Optional)',
            'NIN 12345678901',
            controller: _signatoryIdController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Date of Birth',
            'Select date',
            controller: _signatoryDobController,
            readOnly: true,
            onTap: () => _pickDateInto(_signatoryDobController),
          ),
          const SizedBox(height: 16),
          _buildUploadCard(
            label: 'Identity Document',
            selectedPath: _identityDocumentLocalPath,
            onTap: () async {
              final path = await pickSingleFilePath(),
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 -]'))],
          );
              if (path != null) {
                setState(() => _identityDocumentLocalPath = path);
              }
            },
          ),
          const SizedBox(height: 36),
          _buildContinueButton(context, selectedCategory),
          const SizedBox(height: 40),
        ],
      ),
    );
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

  Widget _buildTextInput(
    String label,
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? initialValue,
    ValueChanged<String>? onChanged,
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
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(fontSize: 16, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
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

  Widget _buildPickerInput(
    String label,
    String value, {
    required String hint,
    required VoidCallback onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.trim().isEmpty ? hint : value,
                    style: TextStyle(
                      fontSize: 16,
                      color: value.trim().isEmpty
                          ? colors.textTertiary
                          : colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateInto(TextEditingController controller) async {
    final initial =
        DateTime.tryParse(controller.text.trim()) ?? DateTime(2023, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final year = picked.year.toString().padLeft(4, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      controller.text = '$year-$month-$day';
    });
  }

  Future<void> _pickIndustry() async {
    final selected = _industryController.text.trim().isEmpty
        ? _industryOptions.first
        : _industryController.text.trim();
    final next = await SelectionBottomSheet.show(
      context,
      title: 'Select industry',
      options: _industryOptions,
      selected: selected,
    );
    if (next == null) return;
    setState(() {
      _industryController.text = next;
    });
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: colors.surface,
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              items: items.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required String value,
    String? flag,
    required VoidCallback onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                if (flag != null) ...[
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 16, color: colors.textPrimary),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(
    String label, {
    required TextEditingController controller,
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
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: TextStyle(fontSize: 16, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: '+2348012345678',
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

  Widget _buildUploadCard({
    required String label,
    required String? selectedPath,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    final hasFile = (selectedPath ?? '').isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasFile ? colors.accent : colors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  color: hasFile ? colors.accent : colors.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  hasFile ? 'File selected' : 'Browse document',
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _validate() {
    final requiredControllers = [
      _legalBusinessNameController,
      _tinController,
      _identityValueController,
      _dateOfIncorporationController,
      _countryOfIncorporationController,
      _industryController,
      _employeesController,
      _emailController,
      _phoneController,
      _cityController,
      _addressController,
      _postalCodeController,
      _signatoryNameController,
      _signatoryJobTitleController,
      _signatoryEmailController,
      _signatoryPhoneController,
      _signatoryDobController,
    ];
    if (requiredControllers.any((c) => c.text.trim().isEmpty)) {
      AppSnackbars.showError(
        context,
        'Complete all required business compliance fields',
      );
      return false;
    }
    if (_selectedCountryName.isEmpty || _selectedStateName.isEmpty) {
      AppSnackbars.showError(context, 'Select your country and state');
      return false;
    }
    if (_businessNameController.text.trim().isEmpty &&
        _registrationNumberController.text.trim().isEmpty) {
      AppSnackbars.showError(
        context,
        'Provide either business name or registration number',
      );
      return false;
    }
    if (_identityDocumentLocalPath == null ||
        _identityDocumentLocalPath!.isEmpty) {
      AppSnackbars.showError(context, 'Upload the identity document');
      return false;
    }
    if (int.tryParse(_employeesController.text.trim()) == null) {
      AppSnackbars.showError(context, 'Number of employees must be numeric');
      return false;
    }
    return true;
  }

  Widget _buildContinueButton(BuildContext context, String selectedCategory) {
    final colors = context.appColors;
    return InkWell(
      onTap: () async {
        if (!_validate()) return;

        final args = ModalRoute.of(context)?.settings.arguments;
        final draftFromArgs = (args is Map<String, dynamic>)
            ? BusinessRegistrationDraft.fromJson(args)
            : null;
        final draft =
            (draftFromArgs ??
                  BusinessRegistrationDraft(categoryLabel: selectedCategory))
              ..businessName = _businessNameController.text.trim()
              ..legalBusinessName = _legalBusinessNameController.text.trim()
              ..tradingName = _tradingNameController.text.trim()
              ..businessRegistrationNumber = _registrationNumberController.text
                  .trim()
              ..taxIdentificationNumber = _tinController.text.trim()
              ..nin = _identityType == 'nin'
                  ? _identityValueController.text.trim()
                  : null
              ..bvn = _identityType == 'bvn'
                  ? _identityValueController.text.trim()
                  : null
              ..dateOfIncorporation = _dateOfIncorporationController.text.trim()
              ..countryOfIncorporation = _countryOfIncorporationController.text
                  .trim()
              ..industrySector = _industryController.text.trim()
              ..businessType = _businessType
              ..otherBusinessType = _otherBusinessType.trim()
              ..numberOfEmployees = int.tryParse(
                _employeesController.text.trim(),
              )
              ..annualTurnoverRange = _turnoverRange
              ..website = _websiteController.text.trim()
              ..businessEmail = _emailController.text.trim()
              ..businessPhoneNumber = _phoneController.text.trim()
              ..country = _selectedCountryName
              ..state = _selectedStateName
              ..city = _cityController.text.trim()
              ..address = _addressController.text.trim()
              ..postalCode = _postalCodeController.text.trim()
              ..authorizedSignatoryFullName = _signatoryNameController.text
                  .trim()
              ..authorizedSignatoryJobTitle = _signatoryJobTitleController.text
                  .trim()
              ..authorizedSignatoryEmail = _signatoryEmailController.text.trim()
              ..authorizedSignatoryPhoneNumber = _signatoryPhoneController.text
                  .trim()
              ..authorizedSignatoryIdNumber =
                  _signatoryIdController.text.trim().isNotEmpty
                  ? _signatoryIdController.text.trim()
                  : '${_identityType.toUpperCase()}:${_identityValueController.text.trim()}'
              ..authorizedSignatoryDateOfBirth = _signatoryDobController.text
                  .trim()
              ..identityDocumentPath = _identityDocumentLocalPath
              ..youtube = null
              ..spotify = null;

        if (draft.categoryId == null || draft.subcategoryId == null) {
          final catalog = await ref.read(allCategoriesProvider.future);
          if (!context.mounted) return;
          final roots = catalog.categories['school'] ?? const <CategoryNode>[];
          final selectedNode = await showCategoryTreePickerSheet(
            context: context,
            title: 'Select Category',
            roots: roots,
          );
          if (!context.mounted) return;
          if (selectedNode == null) return;
          draft
            ..categoryId = selectedNode.parentId ?? selectedNode.id
            ..subcategoryId = selectedNode.id;
        }

        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.businessSchoolsForm, arguments: draft.toJson());
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 56,
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
            'Save and Continue',
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
