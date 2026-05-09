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

import '../../../../../app/router/app_router.dart';
import 'draft_utils.dart';

class SellerRegistrationScreen extends ConsumerStatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  ConsumerState<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState
    extends ConsumerState<SellerRegistrationScreen> {
  bool _initializedFromDraft = false;

  final _businessNameController = TextEditingController();
  final _legalBusinessNameController = TextEditingController();
  final _tradingNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _tinController = TextEditingController();
  final _identityValueController = TextEditingController();
  final _dateOfIncorporationController = TextEditingController();
  final _countryOfIncorporationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _industryController = TextEditingController();
  final _employeesController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _signatoryNameController = TextEditingController();
  final _signatoryJobTitleController = TextEditingController();
  final _signatoryEmailController = TextEditingController();
  final _signatoryPhoneController = TextEditingController();
  final _signatoryIdController = TextEditingController();
  final _signatoryDobController = TextEditingController();
  final _ninController = TextEditingController();
  final _bvnController = TextEditingController();

  String _selectedCountryName = '';
  String _selectedCountryFlag = '';
  String _selectedStateName = '';
  String _selectedCountryCode = '';
  String _businessType = 'limited_liability_company';
  String _turnoverRange = '50000_to_250000';
  String _annualTurnoverCurrency = 'NGN';
  String _otherBusinessType = '';

  // True when opened from 'Edit Business Information' (pre-filled draft)
  bool get _isEditing => (ModalRoute.of(context)?.settings.arguments is Map);
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
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _industryController.dispose();
    _employeesController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _signatoryNameController.dispose();
    _signatoryJobTitleController.dispose();
    _signatoryEmailController.dispose();
    _signatoryPhoneController.dispose();
    _signatoryIdController.dispose();
    _signatoryDobController.dispose();
    _ninController.dispose();
    _bvnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = sellerDraftFromArgs(
      ModalRoute.of(context)?.settings.arguments,
    );
    if (!_initializedFromDraft) {
      _initializedFromDraft = true;
      _businessNameController.text = draft.businessName ?? '';
      _legalBusinessNameController.text = draft.legalBusinessName ?? '';
      _tradingNameController.text = draft.tradingName ?? '';
      _registrationNumberController.text =
          draft.businessRegistrationNumber ?? '';
      _tinController.text = draft.taxIdentificationNumber ?? '';
      _ninController.text = draft.nin ?? '';
      _bvnController.text = draft.bvn ?? '';
      _dateOfIncorporationController.text = draft.dateOfIncorporation ?? '';
      _countryOfIncorporationController.text =
          draft.countryOfIncorporation ?? '';
      _websiteController.text = draft.websiteUrl ?? '';
      _emailController.text = draft.businessEmail ?? '';
      _phoneController.text = draft.businessPhoneNumber ?? '';
      _industryController.text = draft.industrySector ?? '';
      _employeesController.text = draft.numberOfEmployees?.toString() ?? '';
      _selectedCountryName = draft.country ?? '';
      _selectedStateName = draft.state ?? '';
      _cityController.text = draft.city ?? '';
      _addressController.text = draft.address ?? '';
      _postalCodeController.text = draft.postalCode ?? '';
      _signatoryNameController.text = draft.authorizedSignatoryFullName ?? '';
      _signatoryJobTitleController.text =
          draft.authorizedSignatoryJobTitle ?? '';
      _signatoryEmailController.text = draft.authorizedSignatoryEmail ?? '';
      _signatoryPhoneController.text =
          draft.authorizedSignatoryPhoneNumber ?? '';
      _signatoryIdController.text = draft.authorizedSignatoryIdNumber ?? '';
      _signatoryDobController.text = draft.authorizedSignatoryDateOfBirth ?? '';
      _businessType = draft.businessType ?? _businessType;
      _turnoverRange = draft.annualTurnoverRange ?? _turnoverRange;
      _annualTurnoverCurrency = draft.annualTurnoverCurrency ?? _annualTurnoverCurrency;
      _otherBusinessType = draft.otherBusinessType ?? '';
      _identityDocumentLocalPath = draft.identityDocumentPath;
    }

    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ComplianceProgressBanner(
            title: _isEditing ? 'Edit Business Information' : 'Seller compliance onboarding',
            subtitle: _isEditing
                ? 'Update your business profile details. Changes will be sent for review.'
                : 'Complete your legal business profile. This first page covers identity, business registration, registered address, and signatory details.',
            currentSection: 'Business Information',
            sectionLabels: _sections,
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 1: Business Information'),
          const SizedBox(height: 16),
          _buildTextInput(
            'Business Name on Ojaewa or Business Name',
            'Oja Ewa Studio',
            controller: _businessNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Legal Business Name',
            'Oja Ewa Studio Limited',
            controller: _legalBusinessNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Trading Name',
            'Oja Ewa',
            controller: _tradingNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Business Registration Number',
            'RC1234567',
            controller: _registrationNumberController,
            maxLength: 20,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9/\-]'))],
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Tax Identification Number',
            '12345678-0001',
            controller: _tinController,
            maxLength: 14,
          ),
          const SizedBox(height: 16),
          if (_isNigerianSeller) ...[
            _buildTextInput(
              'NIN (11 digits)',
              '12345678901',
              controller: _ninController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            _buildTextInput(
              'BVN (11 digits)',
              '12345678901',
              controller: _bvnController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ] else ...[
            _buildTextInput(
              'Passport / Government ID Number',
              'A12345678',
              controller: _identityValueController,
              maxLength: 9,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
            ),
          ],
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
          _buildWebsiteInput(
            'Business Website',
            'yoursite.com',
            controller: _websiteController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Business Email',
            'hello@example.com',
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          _buildPhoneInputWithPicker(
            'Business Phone Number',
            controller: _phoneController,
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 2: Business Type & Industry'),
          const SizedBox(height: 16),
          _buildPickerInput(
            'Industry / Sector',
            _industryController.text,
            hint: 'Select industry',
            onTap: _pickIndustry,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Business Type',
            value: _businessType,
            items: const {
              'limited_liability_company': 'Limited Liability Company',
              'partnership': 'Partnership',
              'sole_proprietorship_corporate':
                  'Sole Proprietorship (Corporate)',
              'non_profit_ngo': 'Non-Profit / NGO',
              'other': 'Other',
            },
            onChanged: (value) => setState(() => _businessType = value),
          ),
          if (_businessType == 'other') ...[
            const SizedBox(height: 16),
            _buildTextInput(
              'Other Business Type',
              'Describe business type',
              initialValue: _otherBusinessType,
              onChanged: (value) => _otherBusinessType = value,
            ),
          ],
          const SizedBox(height: 16),
          _buildTextInput(
            'Number of Employees',
            '12',
            controller: _employeesController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Currency selector
              SizedBox(
                width: 100,
                child: _buildDropdown(
                  label: 'Currency',
                  value: _annualTurnoverCurrency,
                  items: const {
                    'NGN': '₦ NGN',
                    'USD': '\$ USD',
                    'GBP': '£ GBP',
                    'EUR': '€ EUR',
                  },
                  onChanged: (v) => setState(() => _annualTurnoverCurrency = v),
                ),
              ),
              const SizedBox(width: 12),
              // Turnover range
              Expanded(
                child: _buildDropdown(
                  label: 'Annual Turnover',
                  value: _turnoverRange,
                  items: {
                    'under_50000': '< 50,000',
                    '50000_to_250000': '50,000 – 250,000',
                    '250000_to_1000000': '250,000 – 1M',
                    'over_1000000': '> 1M',
                  },
                  onChanged: (value) => setState(() => _turnoverRange = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSectionHeader(
            'Section 3: Registered Office / Physical Address',
          ),
          const SizedBox(height: 16),
          _buildLocationDropdown(
            label: 'Country',
            value: _selectedCountryName.isEmpty
                ? 'Select Country'
                : _selectedCountryName,
            flag: _selectedCountryFlag.isEmpty ? null : _selectedCountryFlag,
            onTap: () async {
              final country = await CountryPickerSheet.show(
                context,
                selectedCountry: _selectedCountryName,
              );
              if (country != null) {
                setState(() {
                  _selectedCountryName = country.name;
                  _selectedCountryFlag = country.flag;
                  _selectedCountryCode = country.dialCode;
                  _selectedStateName = '';
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
            'Lagos',
            controller: _cityController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Street Address',
            '12 Allen Avenue',
            controller: _addressController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Postal / Zip Code',
            '100001',
            controller: _postalCodeController,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 -]'))],
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 4: Authorized Signatory'),
          const SizedBox(height: 16),
          _buildTextInput(
            'Full Name',
            'Ada Okafor',
            controller: _signatoryNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Job Title',
            'Director',
            controller: _signatoryJobTitleController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Email Address',
            'ada@example.com',
            controller: _signatoryEmailController,
          ),
          const SizedBox(height: 16),
          _buildPhoneInputWithPicker(
            'Phone Number',
            controller: _signatoryPhoneController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'National ID / Passport Number (Optional)',
            'A12345678',
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
          _buildFileUploadSection(),
          const SizedBox(height: 36),
          _buildSubmitButton(context),
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
    String? initialValue,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixWidget,
    Widget? suffixWidget,
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
          keyboardType: keyboardType,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 16, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary),
            prefix: prefixWidget,
            suffix: suffixWidget,
            counterText: '',
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
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
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
                  Text(flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: (value == 'Select Country' || value == 'Select State')
                          ? colors.textTertiary
                          : colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Website input that pre-fills https:// and allows the user to clear it fully
  Widget _buildWebsiteInput(
    String label,
    String hint, {
    required TextEditingController controller,
  }) {
    final colors = context.appColors;
    // Ensure controller starts with https:// if empty
    if (controller.text.isEmpty) {
      controller.text = 'https://';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          style: TextStyle(fontSize: 16, color: colors.textPrimary),
          onChanged: (val) {
            // If user deletes everything, restore prefix so it's still deleteable
            // but the field remains usable
          },
          decoration: InputDecoration(
            hintText: 'https://$hint',
            hintStyle: TextStyle(color: colors.textTertiary),
            counterText: '',
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: colors.border),
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

  /// Shows country picker for a nationality/text field
  Future<void> _pickCountryInto(TextEditingController ctrl) async {
    final country = await CountryPickerSheet.show(
      context,
      selectedCountry: ctrl.text,
    );
    if (country != null && mounted) {
      setState(() => ctrl.text = country.name);
    }
  }

  Widget _buildPhoneInputWithPicker(
    String label, {
    required TextEditingController controller,
  }) {
    final colors = context.appColors;
    final hasCountryCode = _selectedCountryCode.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final country = await CountryCodePickerSheet.show(
                    context,
                    selectedDialCode: _selectedCountryCode,
                  );
                  if (country != null) {
                    setState(() {
                      _selectedCountryCode = country.dialCode;
                      _selectedCountryFlag = country.flag;
                    });
                  }
                },
                child: Row(
                  children: [
                    if (hasCountryCode) ...[
                      Text(
                        _selectedCountryFlag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountryCode,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ] else
                      Text(
                        'Code',
                        style: TextStyle(color: colors.textTertiary),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, color: colors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(color: colors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    final colors = context.appColors;
    return InkWell(
      onTap: () async {
        final path = await pickSingleFilePath();
        if (path == null) return;
        setState(() => _identityDocumentLocalPath = path);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isNigerianSeller
                ? 'Identity Document Upload'
                : 'International Passport Upload',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.borderStrong),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 24,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  _identityDocumentLocalPath == null
                      ? 'Browse document'
                      : 'Document selected',
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _validateStep1() {
    final requiredControllers = [
      _legalBusinessNameController,
      _dateOfIncorporationController,
      _countryOfIncorporationController,
      _emailController,
      _phoneController,
      _industryController,
      _employeesController,
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
        'Complete all required compliance fields',
      );
      return false;
    }
    if (_selectedCountryName.isEmpty || _selectedStateName.isEmpty) {
      AppSnackbars.showError(context, 'Select your country and state');
      return false;
    }
    if (_isNigerianSeller) {
      if (_tinController.text.trim().isEmpty) {
        AppSnackbars.showError(context, 'Provide Tax Identification Number');
        return false;
      }
      if (_ninController.text.trim().isEmpty) {
        AppSnackbars.showError(context, 'Please provide your NIN');
        return false;
      }
      if (_bvnController.text.trim().isEmpty) {
        AppSnackbars.showError(context, 'Please provide your BVN');
        return false;
      }
      if (_registrationNumberController.text.trim().isEmpty) {
        AppSnackbars.showError(
          context,
          'Complete CAC registration before seller submission',
        );
        Navigator.of(context).pushNamed(AppRoutes.cacServices);
        return false;
      }
    }
    if (_businessNameController.text.trim().isEmpty &&
        _registrationNumberController.text.trim().isEmpty) {
      AppSnackbars.showError(
        context,
        'Provide either business name or registration number',
      );
      return false;
    }
    if (_isNigerianSeller &&
        (_identityDocumentLocalPath == null ||
            _identityDocumentLocalPath!.isEmpty)) {
      AppSnackbars.showError(context, 'Upload the identity document');
      return false;
    }
    if (int.tryParse(_employeesController.text.trim()) == null) {
      AppSnackbars.showError(context, 'Number of employees must be numeric');
      return false;
    }
    return true;
  }

  Widget _buildSubmitButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        if (!_validateStep1()) return;
        final draft =
            sellerDraftFromArgs(ModalRoute.of(context)?.settings.arguments)
              ..businessName = _businessNameController.text.trim()
              ..legalBusinessName = _legalBusinessNameController.text.trim()
              ..tradingName = _tradingNameController.text.trim()
              ..businessRegistrationNumber = _registrationNumberController.text
                  .trim()
              ..taxIdentificationNumber = _tinController.text.trim()
              ..nin = _isNigerianSeller ? _ninController.text.trim() : null
              ..bvn = _isNigerianSeller ? _bvnController.text.trim() : null
              ..dateOfIncorporation = _dateOfIncorporationController.text.trim()
              ..countryOfIncorporation = _countryOfIncorporationController.text
                  .trim()
              ..websiteUrl = _websiteController.text.trim()
              ..businessEmail = _emailController.text.trim()
              ..businessPhoneNumber = _phoneController.text.trim()
              ..industrySector = _industryController.text.trim()
              ..businessType = _businessType
              ..otherBusinessType = _otherBusinessType.trim()
              ..numberOfEmployees = int.tryParse(
                _employeesController.text.trim(),
              )
              ..annualTurnoverRange = _turnoverRange
              ..annualTurnoverCurrency = _annualTurnoverCurrency
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
                  : _defaultSignatoryIdNumber()
              ..authorizedSignatoryDateOfBirth = _signatoryDobController.text
                  .trim()
              ..identityDocumentPath = _identityDocumentLocalPath;

        Navigator.of(
          context,
        ).pushNamed(AppRoutes.businessDetails, arguments: draft.toJson());
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
              color: colors.shadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Continue',
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

  bool get _isNigerianSeller {
    return _isNigeria(_selectedCountryName) ||
        _isNigeria(_countryOfIncorporationController.text);
  }

  bool _isNigeria(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'nigeria' || normalized == 'ng' || normalized == 'nga';
  }

  String _defaultSignatoryIdNumber() {
    if (_isNigerianSeller) {
      final nin = _ninController.text.trim();
      if (nin.isNotEmpty) return 'NIN:$nin';
      final bvn = _bvnController.text.trim();
      if (bvn.isNotEmpty) return 'BVN:$bvn';
      return '';
    }
    final passport = _identityValueController.text.trim();
    if (passport.isEmpty) return '';
    return 'PASSPORT:$passport';
  }
}

/// Forces all input to uppercase (for passport numbers etc.)
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
