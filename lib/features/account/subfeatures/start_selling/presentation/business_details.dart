import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/subfeatures/shared/widgets/compliance_progress_banner.dart';

import 'package:ojaewa/core/location/location_picker_sheets.dart';
import '../../../../../app/router/app_router.dart';
import 'draft_utils.dart';
import 'seller_registration_draft.dart';
import 'widgets/bank_picker_sheet.dart';

class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  bool _initializedFromDraft = false;

  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
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

  String _preferredSettlementCurrency = 'NGN';
  String? _bankCode;
  bool _declarationLegalRegistered = false;
  bool _declarationInformationTrue = false;
  bool _declarationAuthorizeVerification = false;
  bool _authorizeSettlementAccount = false;
  bool _acceptPartnerBankTerms = false;
  String? _businessCertificatePath;
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

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
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
    final draft = sellerDraftFromArgs(
      ModalRoute.of(context)?.settings.arguments,
    );
    if (!_initializedFromDraft) {
      _initializedFromDraft = true;
      _bankNameController.text = draft.bankName ?? '';
      _accountNumberController.text = draft.accountNumber ?? '';
      final owners = draft.beneficialOwners ?? const [];
      if (owners.isNotEmpty) _fillOwnerControllers(owners[0], 1);
      if (owners.length > 1) _fillOwnerControllers(owners[1], 2);
      if (owners.length > 2) _fillOwnerControllers(owners[2], 3);
      _bankNameController.text = draft.bankName ?? '';
      _bankCode = draft.bankCode;
      _accountNumberController.text = draft.accountNumber ?? '';
      _preferredSettlementCurrency =
          draft.preferredSettlementCurrency ?? _preferredSettlementCurrency;
      _declarationLegalRegistered = draft.declarationLegalRegistered ?? false;
      _declarationInformationTrue = draft.declarationInformationTrue ?? false;
      _declarationAuthorizeVerification =
          draft.declarationAuthorizeVerification ?? false;
      _authorizeSettlementAccount = draft.authorizeSettlementAccount ?? false;
      _acceptPartnerBankTerms = draft.acceptPartnerBankTerms ?? false;
      _printedNameController.text =
          draft.printedNameOfAuthorizedSignatory ?? '';
      _submissionDateController.text = draft.submissionDate ?? '';
      _businessCertificatePath = draft.businessCertificatePath;
      _businessLogoPath = draft.businessLogoPath;
      _signaturePath = draft.authorizedSignatorySignaturePath;
    }

    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const ComplianceProgressBanner(
            title: 'Seller compliance onboarding',
            subtitle:
                'Finish ownership, settlement, declarations, and signature. This keeps the flow fluid while still covering all compliance sections.',
            currentSection: 'Beneficial Owners',
            sectionLabels: _sections,
          ),
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
          _buildPickerInput(
            'Bank Name',
            _bankNameController.text,
            hint: 'Select bank',
            onTap: _pickBank,
          ),
          if ((_bankCode ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Bank code will be stored automatically',
              style: TextStyle(
                color: context.appColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildTextInput(
            'Account Number',
            '0123456789',
            controller: _accountNumberController,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Preferred Settlement Currency',
            value: _preferredSettlementCurrency,
            items: const ['USD', 'EUR', 'GBP', 'NGN'],
            onChanged: (value) =>
                setState(() => _preferredSettlementCurrency = value),
          ),
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
                'I authorize WAWUBeauty to verify this information with third parties.',
            onChanged: (value) =>
                setState(() => _declarationAuthorizeVerification = value),
          ),
          _buildCheckTile(
            value: _authorizeSettlementAccount,
            label: 'I authorize WAWUBeauty to open a settlement account for me.',
            onChanged: (value) =>
                setState(() => _authorizeSettlementAccount = value),
          ),
          _buildCheckTile(
            value: _acceptPartnerBankTerms,
            label:
                'I accept WAWUBeauty partner bank terms of service and corporate account agreement.',
            onChanged: (value) =>
                setState(() => _acceptPartnerBankTerms = value),
          ),
          const SizedBox(height: 28),
          _buildSectionHeader('Section 8: Submission & Signature'),
          const SizedBox(height: 16),
          _buildTextInput(
            'Printed Name of Authorized Signatory',
            'Ada Okafor',
            controller: _printedNameController,
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            'Submission Date',
            'Select date',
            controller: _submissionDateController,
            readOnly: true,
            onTap: _pickSubmissionDate,
          ),
          const SizedBox(height: 16),
          _buildUploadCard(
            label: 'Authorized Signatory Signature',
            selectedPath: _signaturePath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) setState(() => _signaturePath = path);
            },
          ),
          const SizedBox(height: 16),
          _buildUploadCard(
            label: _isNigerianDraft(draft)
                ? 'CAC Business Certificate'
                : 'Verified Business Document',
            selectedPath: _businessCertificatePath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) {
                setState(() => _businessCertificatePath = path);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildUploadCard(
            label: 'Business Logo',
            selectedPath: _businessLogoPath,
            onTap: () async {
              final path = await pickSingleFilePath();
              if (path != null) setState(() => _businessLogoPath = path);
            },
          ),
          const SizedBox(height: 36),
          _buildSubmitButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _fillOwnerControllers(Map<String, dynamic> owner, int index) {
    final controllers = _ownerControllers(index);
    controllers.$1.text = (owner['full_name'] as String?) ?? '';
    controllers.$2.text = (owner['ownership_percentage']?.toString()) ?? '';
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
      final controllers = _ownerControllers(i);
      final name = controllers.$1.text.trim();
      final percentage = controllers.$2.text.trim();
      final nationality = controllers.$3.text.trim();
      final id = controllers.$4.text.trim();
      // Only send owners whose every required field is present. Partial rows
      // are rejected earlier in _validateStep2; here we simply drop any row
      // that isn't fully complete so no empty strings reach the backend.
      if (name.isEmpty ||
          percentage.isEmpty ||
          nationality.isEmpty ||
          id.isEmpty) {
        continue;
      }
      owners.add({
        'full_name': name,
        'ownership_percentage': num.tryParse(percentage) ?? 0,
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

  Widget _buildOwnerCard(int index) {
    final controllers = _ownerControllers(index);
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
          _buildTextInput(
            'Full Name',
            'Ada Okafor',
            controller: controllers.$1,
          ),
          const SizedBox(height: 12),
          _buildTextInput(
            'Ownership % (max 100)',
            '60',
            controller: controllers.$2,
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
            value: controllers.$3.text.isEmpty ? 'Select Country' : controllers.$3.text,
            onTap: () async {
              final country = await CountryPickerSheet.show(
                context,
                selectedCountry: controllers.$3.text,
              );
              if (country != null && mounted) {
                setState(() => controllers.$3.text = country.name);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildTextInput(
            'ID Type & Number',
            'Passport A12345678',
            controller: controllers.$4,
            maxLength: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    String label,
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 16, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
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
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
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

  bool _validateStep2() {
    if (_bankNameController.text.trim().isEmpty ||
        _accountNumberController.text.trim().isEmpty ||
        _printedNameController.text.trim().isEmpty ||
        _submissionDateController.text.trim().isEmpty) {
      AppSnackbars.showError(
        context,
        'Complete the settlement and signature fields',
      );
      return false;
    }
    // Each owner row must be either entirely empty or fully complete. A row
    // with some (but not all) of full name, ownership %, nationality and ID
    // filled would send empty strings and trigger a 422 via `required_with`.
    for (var i = 1; i <= 3; i++) {
      final controllers = _ownerControllers(i);
      final fields = [
        controllers.$1.text.trim(),
        controllers.$2.text.trim(),
        controllers.$3.text.trim(),
        controllers.$4.text.trim(),
      ];
      final filled = fields.where((value) => value.isNotEmpty).length;
      if (filled > 0 && filled < fields.length) {
        AppSnackbars.showError(
          context,
          'Owner $i is incomplete. Fill full name, ownership %, nationality and '
          'ID, or clear the row entirely.',
        );
        return false;
      }
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
      AppSnackbars.showError(
        context,
        'All compliance declarations are required',
      );
      return false;
    }
    if ((_signaturePath ?? '').isEmpty) {
      AppSnackbars.showError(
        context,
        'Upload the authorized signatory signature',
      );
      return false;
    }
    final draft = sellerDraftFromArgs(
      ModalRoute.of(context)?.settings.arguments,
    );
    if (_isNigerianDraft(draft) && (_businessCertificatePath ?? '').isEmpty) {
      AppSnackbars.showError(
        context,
        'Upload your CAC business certificate before seller submission',
      );
      return false;
    }
    if (!_isNigerianDraft(draft) &&
        (_businessCertificatePath ?? '').isEmpty &&
        (draft.identityDocumentPath ?? '').isEmpty) {
      AppSnackbars.showError(
        context,
        'Upload a verified business document or international passport',
      );
      return false;
    }
    return true;
  }

  Widget _buildSubmitButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        if (!_validateStep2()) return;
        final draft =
            sellerDraftFromArgs(ModalRoute.of(context)?.settings.arguments)
              ..bankName = _bankNameController.text.trim()
              ..bankCode = _bankCode ?? ''
              ..accountNumber = _accountNumberController.text.trim()
              ..beneficialOwners = _beneficialOwners()
              ..preferredSettlementCurrency = _preferredSettlementCurrency
              ..declarationLegalRegistered = _declarationLegalRegistered
              ..declarationInformationTrue = _declarationInformationTrue
              ..declarationAuthorizeVerification =
                  _declarationAuthorizeVerification
              ..authorizeSettlementAccount = _authorizeSettlementAccount
              ..acceptPartnerBankTerms = _acceptPartnerBankTerms
              ..printedNameOfAuthorizedSignatory = _printedNameController.text
                  .trim()
              ..authorizedSignatorySignaturePath = _signaturePath
              ..submissionDate = _submissionDateController.text.trim()
              ..businessCertificatePath = _businessCertificatePath
              ..businessLogoPath = _businessLogoPath;

        Navigator.of(
          context,
        ).pushNamed(AppRoutes.accountReview, arguments: draft.toJson());
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

  Future<void> _pickBank() async {
    final selected = await BankPickerSheet.show(
      context,
      selectedBankCode: _bankCode,
      country: 'NG',
    );
    if (selected == null) return;
    setState(() {
      _bankCode = selected.code;
      _bankNameController.text = selected.name;
    });
  }

  bool _isNigerianDraft(SellerRegistrationDraft draft) {
    return _isNigeria((draft.country ?? '').toString()) ||
        _isNigeria((draft.countryOfIncorporation ?? '').toString());
  }

  bool _isNigeria(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'nigeria' || normalized == 'ng' || normalized == 'nga';
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
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: value == 'Select Country'
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
