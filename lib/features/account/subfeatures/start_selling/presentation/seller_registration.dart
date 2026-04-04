import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

import '../../../../../app/router/app_router.dart';

import 'draft_utils.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';

class SellerRegistrationScreen extends ConsumerStatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  ConsumerState<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState
    extends ConsumerState<SellerRegistrationScreen> {
  bool _initializedFromDraft = false;
  final _cityController = TextEditingController();
  String? _identityDocumentLocalPath;
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();

  // Location selections
  // Location selections - empty by default
  String _selectedCountryName = '';
  String _selectedCountryFlag = '';
  String _selectedStateName = '';
  String _selectedCountryCode = '';

  @override
  void dispose() {
    _cityController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = sellerDraftFromArgs(
      ModalRoute.of(context)?.settings.arguments,
    );
    if (!_initializedFromDraft) {
      _initializedFromDraft = true;
      _selectedCountryName = draft.country ?? '';
      _selectedCountryFlag = '';
      _selectedStateName = draft.state ?? '';
      _cityController.text = draft.city ?? '';
      _addressController.text = draft.address ?? '';
      _emailController.text = draft.businessEmail ?? '';
      _phoneController.text = draft.businessPhoneNumber ?? '';
      _instagramController.text = draft.instagram ?? '';
      _facebookController.text = draft.facebook ?? '';
      _identityDocumentLocalPath = draft.identityDocumentPath;
    }
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildStepper(),
          const SizedBox(height: 32),

          // --- Location Section ---
          _buildSectionHeader("Location"),
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
          const SizedBox(height: 20),
          _buildLocationDropdown(
            label: 'State',
            value: _selectedStateName.isEmpty
                ? 'Select State'
                : _selectedStateName,
            onTap: () async {
              if (_selectedCountryName.isEmpty) {
                return;
              }
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
          const SizedBox(height: 20),
          _buildTextInput("City", "Your City", controller: _cityController),
          const SizedBox(height: 20),
          _buildTextInput(
            "Address Line",
            "Street, house number etc",
            controller: _addressController,
          ),

          const SizedBox(height: 40),

          // --- Contacts Section ---
          _buildSectionHeader("Contacts"),
          const SizedBox(height: 16),
          _buildTextInput(
            "Business Email",
            "you@example.com",
            controller: _emailController,
          ),
          const SizedBox(height: 20),
          _buildPhoneInputWithPicker(
            "Business Phone Number",
            controller: _phoneController,
          ),

          const SizedBox(height: 40),

          // --- Social handles Section ---
          _buildSectionHeader("Social handles"),
          const SizedBox(height: 16),
          _buildTextInput(
            "Instagram",
            "Your Instagram URL",
            controller: _instagramController,
          ),
          const SizedBox(height: 20),
          _buildTextInput(
            "Facebook",
            "Your Facebook URL",
            controller: _facebookController,
          ),

          const SizedBox(height: 40),

          // --- Means Identification Section ---
          _buildSectionHeader("Means Identification"),
          const SizedBox(height: 16),
          _buildFileUploadSection(),

          const SizedBox(height: 40),

          _buildSubmitButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper: Stepper UI
  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepCircle("1", "Basic\nInfo", true),
        _stepCircle("2", "Business\nDetails", false),
        _stepCircle("3", "Account\non review", false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive) {
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
          alignment: Alignment.center,
          child: Text(
            num,
            style: TextStyle(
              color: isActive ? colors.background : colors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: isActive ? colors.textPrimary : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextInput(
    String label,
    String hint, {
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
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
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
          height: 49,
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
                  mainAxisSize: MainAxisSize.min,
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
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textTertiary,
                        ),
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
            'Upload Document',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
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
                const SizedBox(height: 12),
                Text(
                  _identityDocumentLocalPath == null
                      ? 'Browse Document'
                      : 'Document selected',
                  style: TextStyle(fontSize: 16, color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'High resolution image\nPDF, JPG, PNG formats',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '200 x 200px\n20kb max',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        final draft =
            sellerDraftFromArgs(ModalRoute.of(context)?.settings.arguments)
              ..country = _selectedCountryName
              ..state = _selectedStateName
              ..city = _cityController.text.trim()
              ..address = _addressController.text.trim()
              ..businessEmail = _emailController.text.trim()
              ..businessPhoneNumber = _phoneController.text.trim()
              ..instagram = _instagramController.text.trim()
              ..facebook = _facebookController.text.trim()
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
