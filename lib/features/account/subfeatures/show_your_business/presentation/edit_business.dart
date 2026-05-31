import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/multipart_utils.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/account/subfeatures/shared/widgets/compliance_progress_banner.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/domain/business_profile_payload.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_management_controller.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_status_controller.dart';

class EditBusinessScreen extends ConsumerStatefulWidget {
  const EditBusinessScreen({super.key});

  @override
  ConsumerState<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  bool _initialized = false;

  final _businessNameController = TextEditingController();
  final _legalBusinessNameController = TextEditingController();
  final _tradingNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _tinController = TextEditingController();
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
  final _descriptionController = TextEditingController();
  final _signatoryNameController = TextEditingController();
  final _signatoryJobTitleController = TextEditingController();
  final _signatoryEmailController = TextEditingController();
  final _signatoryPhoneController = TextEditingController();
  final _signatoryIdController = TextEditingController();
  final _signatoryDobController = TextEditingController();
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

  String _selectedCountryName = '';
  String _selectedCountryFlag = '';
  String _selectedStateName = '';
  String _businessType = 'limited_liability_company';
  String _turnoverRange = '50000_to_250000';
  String _otherBusinessType = '';
  String _preferredSettlementCurrency = 'NGN';
  bool _declarationLegalRegistered = false;
  bool _declarationInformationTrue = false;
  bool _declarationAuthorizeVerification = false;
  bool _authorizeSettlementAccount = false;
  bool _acceptPartnerBankTerms = false;

  String? _identityDocumentPath;
  String? _businessCertificatesPath;
  String? _businessLogoPath;
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
    _descriptionController.dispose();
    _signatoryNameController.dispose();
    _signatoryJobTitleController.dispose();
    _signatoryEmailController.dispose();
    _signatoryPhoneController.dispose();
    _signatoryIdController.dispose();
    _signatoryDobController.dispose();
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
    final args = ModalRoute.of(context)?.settings.arguments;
    final businessId = (args is Map ? args['businessId'] : null) as int?;
    if (businessId == null) {
      return const AppPageScaffold(
        title: 'Edit Business',
        child: Center(child: Text('Business not found')),
      );
    }

    final businessAsync = ref.watch(businessByIdProvider(businessId));
    return businessAsync.when(
      loading: () => const AppPageScaffold(
        title: 'Edit Business',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => AppPageScaffold(
        title: 'Edit Business',
        child: Center(child: Text(UiErrorMessage.from(error))),
      ),
      data: (res) {
        final data = res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : res;
        _hydrateOnce(data);

        return AppPageScaffold(
          title: 'Edit Business',
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ComplianceProgressBanner(
                title: 'Business compliance edit',
                subtitle:
                    'Update the legal business profile and submit the full current state back for review.',
                currentSection: 'Business Information',
                sectionLabels: _sections,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Section 1: Business Information'),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Name',
                'Oja Ewa Academy',
                controller: _businessNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Legal Business Name',
                'Oja Ewa Academy Ltd',
                controller: _legalBusinessNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Trading Name',
                'Oja Ewa Academy',
                controller: _tradingNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Registration Number',
                'RC9876543',
                controller: _registrationNumberController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Tax Identification Number',
                '12345678-0002',
                controller: _tinController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Date of Incorporation',
                'Select date',
                controller: _dateOfIncorporationController,
                readOnly: true,
                onTap: () => _pickDateInto(_dateOfIncorporationController),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Country of Incorporation',
                'Nigeria',
                controller: _countryOfIncorporationController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Website',
                'https://ojaewa.com',
                controller: _websiteController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Email',
                'academy@ojaewa.com',
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Phone Number',
                '+2348012345678',
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Business Description',
                'Creative education services',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Section 2: Business Type & Industry'),
              const SizedBox(height: 16),
              _buildPickerField(
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
                _buildTextField(
                  'Other Business Type',
                  'Describe business type',
                  initialValue: _otherBusinessType,
                  onChanged: (value) => _otherBusinessType = value,
                ),
              ],
              const SizedBox(height: 16),
              _buildTextField(
                'Number of Employees',
                '20',
                controller: _employeesController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Annual Turnover',
                value: _turnoverRange,
                items: const {
                  'under_50000': '< \$50,000',
                  '50000_to_250000': '\$50,000 – \$250,000',
                  '250000_to_1000000': '\$250,000 – \$1M',
                  'over_1000000': '> \$1M',
                },
                onChanged: (value) => setState(() => _turnoverRange = value),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                'Section 3: Registered Office / Physical Address',
              ),
              const SizedBox(height: 16),
              _buildLocationDropdown(
                label: 'Country',
                value: _selectedCountryName.isEmpty
                    ? 'Select Country'
                    : _selectedCountryName,
                flag: _selectedCountryFlag.isEmpty
                    ? null
                    : _selectedCountryFlag,
                onTap: () async {
                  final country = await CountryPickerSheet.show(
                    context,
                    selectedCountry: _selectedCountryName,
                  );
                  if (!mounted || country == null) return;
                  setState(() {
                    _selectedCountryName = country.name;
                    _selectedCountryFlag = country.flag;
                    _selectedStateName = '';
                  });
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
                  if (!mounted || state == null) return;
                  setState(() => _selectedStateName = state.name);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField('City', 'Lekki', controller: _cityController),
              const SizedBox(height: 16),
              _buildTextField(
                'Street Address',
                '5 Admiralty Way',
                controller: _addressController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Postal / Zip Code',
                '106104',
                controller: _postalCodeController,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Section 4: Authorized Signatory'),
              const SizedBox(height: 16),
              _buildTextField(
                'Full Name',
                'Kemi James',
                controller: _signatoryNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Job Title',
                'CEO',
                controller: _signatoryJobTitleController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Email Address',
                'kemi@ojaewa.com',
                controller: _signatoryEmailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Phone Number',
                '+2348022222222',
                controller: _signatoryPhoneController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'National ID / Passport Number',
                'NIN 12345678901',
                controller: _signatoryIdController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Date of Birth',
                'Select date',
                controller: _signatoryDobController,
                readOnly: true,
                onTap: () => _pickDateInto(_signatoryDobController),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Section 5: Beneficial Owners'),
              const SizedBox(height: 16),
              _buildOwnerCard(1),
              const SizedBox(height: 16),
              _buildOwnerCard(2),
              const SizedBox(height: 16),
              _buildOwnerCard(3),
              const SizedBox(height: 24),
              _buildSectionHeader(
                'Section 6: Banking & Settlement Preferences',
              ),
              const SizedBox(height: 16),
              _buildCurrencyDropdown(),
              const SizedBox(height: 24),
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
                label:
                    'I authorize Ojaewa to open a settlement account for me.',
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
              const SizedBox(height: 24),
              _buildSectionHeader('Section 8: Submission & Signature'),
              const SizedBox(height: 16),
              _buildTextField(
                'Printed Name of Authorized Signatory',
                'Kemi James',
                controller: _printedNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Submission Date',
                'Select date',
                controller: _submissionDateController,
                readOnly: true,
                onTap: () =>
                    _pickDateInto(_submissionDateController, allowFuture: true),
              ),
              const SizedBox(height: 16),
              _buildDocumentSection(
                title: 'Authorized Signatory Signature',
                selectedPath: _signaturePath,
                onTap: () async {
                  final path = await pickSingleFilePath();
                  if (path != null) setState(() => _signaturePath = path);
                },
              ),
              const SizedBox(height: 16),
              _buildDocumentSection(
                title: 'Identity Document',
                selectedPath: _identityDocumentPath,
                onTap: () async {
                  final path = await pickSingleFilePath();
                  if (path != null) {
                    setState(() => _identityDocumentPath = path);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDocumentSection(
                title: 'Business Certificate',
                selectedPath: _businessCertificatesPath,
                onTap: () async {
                  final path = await pickSingleFilePath();
                  if (path != null) {
                    setState(() => _businessCertificatesPath = path);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDocumentSection(
                title: 'Business Logo',
                selectedPath: _businessLogoPath,
                onTap: () async {
                  final path = await pickSingleFilePath();
                  if (path != null) setState(() => _businessLogoPath = path);
                },
              ),
              const SizedBox(height: 36),
              _buildSubmitButton(businessId, data),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _hydrateOnce(Map<String, dynamic> data) {
    if (_initialized) return;
    _selectedCountryName = (data['country'] as String?) ?? '';
    _selectedStateName = (data['state'] as String?) ?? '';
    _cityController.text = (data['city'] as String?) ?? '';
    _addressController.text = (data['address'] as String?) ?? '';
    _postalCodeController.text = (data['postal_code'] as String?) ?? '';
    _emailController.text = (data['business_email'] as String?) ?? '';
    _phoneController.text =
        ((data['business_phone'] ?? data['business_phone_number'])
            as String?) ??
        '';
    _websiteController.text =
        ((data['website'] ?? data['website_url']) as String?) ?? '';
    _businessNameController.text = (data['business_name'] as String?) ?? '';
    _legalBusinessNameController.text =
        (data['legal_business_name'] as String?) ?? '';
    _tradingNameController.text = (data['trading_name'] as String?) ?? '';
    _descriptionController.text =
        ((data['school_biography'] ?? data['business_description'])
            as String?) ??
        '';
    _registrationNumberController.text =
        (data['business_registration_number'] as String?) ?? '';
    _tinController.text = (data['tax_identification_number'] as String?) ?? '';
    _dateOfIncorporationController.text =
        (data['date_of_incorporation'] as String?) ?? '';
    _countryOfIncorporationController.text =
        (data['country_of_incorporation'] as String?) ?? '';
    _industryController.text = (data['industry_sector'] as String?) ?? '';
    _businessType = (data['business_type'] as String?) ?? _businessType;
    _otherBusinessType = (data['other_business_type'] as String?) ?? '';
    _employeesController.text = '${(data['number_of_employees'] ?? '')}';
    _turnoverRange =
        (data['annual_turnover_range'] as String?) ?? _turnoverRange;
    _signatoryNameController.text =
        (data['authorized_signatory_full_name'] as String?) ?? '';
    _signatoryJobTitleController.text =
        (data['authorized_signatory_job_title'] as String?) ?? '';
    _signatoryEmailController.text =
        (data['authorized_signatory_email'] as String?) ?? '';
    _signatoryPhoneController.text =
        (data['authorized_signatory_phone_number'] as String?) ?? '';
    _signatoryIdController.text =
        (data['authorized_signatory_id_number'] as String?) ?? '';
    _signatoryDobController.text =
        (data['authorized_signatory_date_of_birth'] as String?) ?? '';
    _preferredSettlementCurrency =
        (data['preferred_settlement_currency'] as String?) ??
        _preferredSettlementCurrency;
    _declarationLegalRegistered =
        (data['declaration_legal_registered'] as bool?) ?? false;
    _declarationInformationTrue =
        (data['declaration_information_true'] as bool?) ?? false;
    _declarationAuthorizeVerification =
        (data['declaration_authorize_verification'] as bool?) ?? false;
    _authorizeSettlementAccount =
        (data['authorize_settlement_account'] as bool?) ?? false;
    _acceptPartnerBankTerms =
        (data['accept_partner_bank_terms'] as bool?) ?? false;
    _printedNameController.text =
        (data['printed_name_of_authorized_signatory'] as String?) ?? '';
    _submissionDateController.text = (data['submission_date'] as String?) ?? '';
    _identityDocumentPath = data['identity_document'] as String?;
    _businessLogoPath = data['business_logo'] as String?;
    _signaturePath = data['authorized_signatory_signature'] as String?;

    final beneficialOwners = data['beneficial_owners'];
    if (beneficialOwners is List && beneficialOwners.isNotEmpty) {
      _fillOwner(beneficialOwners[0], 1);
      if (beneficialOwners.length > 1) _fillOwner(beneficialOwners[1], 2);
      if (beneficialOwners.length > 2) _fillOwner(beneficialOwners[2], 3);
    }

    final certificates = data['business_certificates'];
    if (certificates is List && certificates.isNotEmpty) {
      final first = certificates.first;
      if (first is Map<String, dynamic>) {
        _businessCertificatesPath =
            (first['file_path'] ?? first['url']) as String?;
      } else if (first is String) {
        _businessCertificatesPath = first;
      }
    }
    _initialized = true;
  }

  void _fillOwner(dynamic owner, int index) {
    if (owner is! Map<String, dynamic>) return;
    final controllers = _ownerControllers(index);
    controllers.$1.text = (owner['full_name'] as String?) ?? '';
    controllers.$2.text = owner['ownership_percentage']?.toString() ?? '';
    controllers.$3.text = (owner['nationality'] as String?) ?? '';
    controllers.$4.text = (owner['id_type_and_number'] as String?) ?? '';
  }

  ({
    TextEditingController $1,
    TextEditingController $2,
    TextEditingController $3,
    TextEditingController $4,
  })
  _ownerControllers(int index) {
    switch (index) {
      case 1:
        return (
          $1: _owner1NameController,
          $2: _owner1PercentageController,
          $3: _owner1NationalityController,
          $4: _owner1IdController,
        );
      case 2:
        return (
          $1: _owner2NameController,
          $2: _owner2PercentageController,
          $3: _owner2NationalityController,
          $4: _owner2IdController,
        );
      default:
        return (
          $1: _owner3NameController,
          $2: _owner3PercentageController,
          $3: _owner3NationalityController,
          $4: _owner3IdController,
        );
    }
  }

  List<Map<String, dynamic>> _beneficialOwners() {
    final owners = <Map<String, dynamic>>[];
    for (var i = 1; i <= 3; i++) {
      final c = _ownerControllers(i);
      final name = c.$1.text.trim();
      final percent = c.$2.text.trim();
      final nationality = c.$3.text.trim();
      final id = c.$4.text.trim();
      if (name.isEmpty &&
          percent.isEmpty &&
          nationality.isEmpty &&
          id.isEmpty) {
        continue;
      }
      owners.add({
        'full_name': name,
        'ownership_percentage': num.tryParse(percent) ?? 0,
        'nationality': nationality,
        'id_type_and_number': id,
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

  Widget _buildTextField(
    String label,
    String hint, {
    int maxLines = 1,
    String? initialValue,
    ValueChanged<String>? onChanged,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.textTertiary, fontSize: 16),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField(
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
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.trim().isEmpty ? hint : value,
                    style: TextStyle(
                      color: value.trim().isEmpty
                          ? colors.textTertiary
                          : colors.textPrimary,
                      fontSize: 16,
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

  Future<void> _pickDateInto(
    TextEditingController controller, {
    bool allowFuture = false,
  }) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: allowFuture
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now(),
    );
    if (picked == null) return;
    final year = picked.year.toString().padLeft(4, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      controller.text = '$year-$month-$day';
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
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: colors.surfaceElevated,
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
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
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

  Widget _buildOwnerCard(int index) {
    final c = _ownerControllers(index);
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
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
          _buildTextField('Full Name', 'Kemi James', controller: c.$1),
          const SizedBox(height: 12),
          _buildTextField(
            'Ownership %',
            '70',
            controller: c.$2,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField('Nationality', 'Nigerian', controller: c.$3),
          const SizedBox(height: 12),
          _buildTextField('ID Type & Number', 'NIN 123...', controller: c.$4),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _preferredSettlementCurrency,
          isExpanded: true,
          dropdownColor: colors.surfaceElevated,
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

  Widget _buildDocumentSection({
    required String title,
    required String? selectedPath,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    final hasFile = (selectedPath ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: hasFile ? colors.accent : colors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 24,
                  color: hasFile ? colors.accent : colors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile ? 'File selected' : 'Browse Document',
                  style: TextStyle(fontSize: 16, color: colors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _validate() {
    final requiredControllers = [
      _legalBusinessNameController,
      _tinController,
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
      _signatoryIdController,
      _signatoryDobController,
      _printedNameController,
      _submissionDateController,
    ];
    if (requiredControllers.any((c) => c.text.trim().isEmpty)) {
      AppSnackbars.showError(
        context,
        'Complete all required compliance fields',
      );
      return false;
    }
    if (_selectedCountryName.isEmpty || _selectedStateName.isEmpty) {
      AppSnackbars.showError(context, 'Select country and state');
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
    if (_beneficialOwners().isEmpty) {
      AppSnackbars.showError(context, 'Add at least one beneficial owner');
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

  Widget _buildSubmitButton(int businessId, Map<String, dynamic> data) {
    final navigator = Navigator.of(context);
    return GestureDetector(
      onTap: () async {
        if (!_validate()) return;

        final payload = BusinessProfilePayload(
          category: (data['category'] as String?) ?? '',
          categoryId: (data['category_id'] as num?)?.toInt() ?? 0,
          subcategoryId: (data['subcategory_id'] as num?)?.toInt() ?? 0,
          businessName: _businessNameController.text.trim(),
          legalBusinessName: _legalBusinessNameController.text.trim(),
          tradingName: _tradingNameController.text.trim(),
          businessDescription: _descriptionController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          businessEmail: _emailController.text.trim(),
          businessPhoneNumber: _phoneController.text.trim(),
          businessRegistrationNumber: _registrationNumberController.text.trim(),
          taxIdentificationNumber: _tinController.text.trim(),
          nin: _derivedNin(),
          bvn: _derivedBvn(),
          dateOfIncorporation: _dateOfIncorporationController.text.trim(),
          countryOfIncorporation: _countryOfIncorporationController.text.trim(),
          industrySector: _industryController.text.trim(),
          businessType: _businessType,
          otherBusinessType: _otherBusinessType.trim(),
          numberOfEmployees: int.tryParse(_employeesController.text.trim()),
          annualTurnoverRange: _turnoverRange,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _selectedStateName,
          postalCode: _postalCodeController.text.trim(),
          country: _selectedCountryName,
          authorizedSignatoryFullName: _signatoryNameController.text.trim(),
          authorizedSignatoryJobTitle: _signatoryJobTitleController.text.trim(),
          authorizedSignatoryEmail: _signatoryEmailController.text.trim(),
          authorizedSignatoryPhoneNumber: _signatoryPhoneController.text.trim(),
          authorizedSignatoryIdNumber: _signatoryIdController.text.trim(),
          authorizedSignatoryDateOfBirth: _signatoryDobController.text.trim(),
          beneficialOwners: _beneficialOwners(),
          preferredSettlementCurrency: _preferredSettlementCurrency,
          declarationLegalRegistered: _declarationLegalRegistered,
          declarationInformationTrue: _declarationInformationTrue,
          declarationAuthorizeVerification: _declarationAuthorizeVerification,
          authorizeSettlementAccount: _authorizeSettlementAccount,
          acceptPartnerBankTerms: _acceptPartnerBankTerms,
          printedNameOfAuthorizedSignatory: _printedNameController.text.trim(),
          authorizedSignatorySignature: _signaturePath,
          submissionDate: _submissionDateController.text.trim(),
          identityDocument: _identityDocumentPath,
          businessLogo: _businessLogoPath,
          offeringType:
              (data['offering_type'] as String?) ?? 'providing_service',
          productList: const [],
          serviceList: const [],
          professionalTitle: data['professional_title'] as String?,
          schoolType: data['school_type'] as String?,
          schoolBiography:
              (data['school_biography'] ?? data['business_description'])
                  as String?,
          classesOffered: const [],
          musicCategory: data['music_category'] as String?,
          youtube: data['youtube'] as String?,
          spotify: data['spotify'] as String?,
        );

        try {
          final api = ref.read(businessProfileApiProvider);
          final updateRes = await api.updateBusiness(businessId, payload);

          if ((_identityDocumentPath ?? '').isNotEmpty &&
              !_identityDocumentPath!.startsWith('http')) {
            await api.uploadFile(
              businessId: businessId,
              fileType: 'identity_document',
              file: multipartFromPath(_identityDocumentPath!),
            );
          }
          if ((_businessLogoPath ?? '').isNotEmpty &&
              !_businessLogoPath!.startsWith('http')) {
            await api.uploadFile(
              businessId: businessId,
              fileType: 'business_logo',
              file: multipartFromPath(_businessLogoPath!),
            );
          }
          if ((_businessCertificatesPath ?? '').isNotEmpty &&
              !_businessCertificatesPath!.startsWith('http')) {
            await api.uploadFile(
              businessId: businessId,
              fileType: 'business_certificates',
              file: multipartFromPath(_businessCertificatesPath!),
            );
          }

          ref.invalidate(myBusinessStatusesProvider);
          ref.invalidate(businessByIdProvider(businessId));
          if (!mounted) return;
          final responseData = updateRes['data'] is Map<String, dynamic>
              ? updateRes['data'] as Map<String, dynamic>
              : updateRes;
          final storeStatus = responseData['store_status'] as String?;
          AppSnackbars.showSuccess(
            context,
            storeStatus == 'pending'
                ? 'Business profile resubmitted for review'
                : 'Business updated',
          );
          if (storeStatus == 'pending') {
            navigator.pushReplacementNamed(AppRoutes.businessApprovalStatus);
          } else {
            navigator.pop();
          }
        } catch (e) {
          if (!mounted) return;
          AppSnackbars.showError(context, UiErrorMessage.from(e));
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
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
            'Save Changes',
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

  String? _derivedNin() {
    final raw = _signatoryIdController.text.trim();
    if (raw.toUpperCase().startsWith('NIN:')) {
      final value = raw.substring(4).trim();
      return value.isEmpty ? null : value;
    }
    return null;
  }

  String? _derivedBvn() {
    final raw = _signatoryIdController.text.trim();
    if (raw.toUpperCase().startsWith('BVN:')) {
      final value = raw.substring(4).trim();
      return value.isEmpty ? null : value;
    }
    return null;
  }
}
