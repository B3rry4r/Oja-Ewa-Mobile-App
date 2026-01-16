import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../../app/router/app_router.dart';


import 'business_registration_draft.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';

class BusinessSellerRegistrationScreen extends ConsumerStatefulWidget {
  const BusinessSellerRegistrationScreen({super.key});

  @override
  ConsumerState<BusinessSellerRegistrationScreen> createState() => _BusinessSellerRegistrationScreenState();
}

class _BusinessSellerRegistrationScreenState extends ConsumerState<BusinessSellerRegistrationScreen> {
  final _cityController = TextEditingController();
  String? _identityDocumentLocalPath;
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  
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
    _websiteController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background from IR
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(104),
        child: AppHeader(
          backgroundColor: Color(0xFFFFF8F1),
          iconColor: Color(0xFF241508),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildStepper(),
            const SizedBox(height: 32),
            
            // --- Location Section ---
            _buildSectionHeader("Location"),
            const SizedBox(height: 16),
            _buildLocationDropdown(label: 'Country', value: _selectedCountryName.isEmpty ? 'Select Country' : _selectedCountryName, flag: _selectedCountryFlag.isEmpty ? null : _selectedCountryFlag, onTap: () async {
              final country = await CountryPickerSheet.show(context, selectedCountry: _selectedCountryName);
              if (country != null) setState(() { _selectedCountryName = country.name; _selectedCountryFlag = country.flag; _selectedCountryCode = country.dialCode; _selectedStateName = ''; });
            }),
            const SizedBox(height: 20),
            _buildLocationDropdown(label: 'State', value: _selectedStateName.isEmpty ? 'Select State' : _selectedStateName, onTap: () async {
              if (_selectedCountryName.isEmpty) return; // Must select country first
              final state = await StatePickerSheet.show(context, countryName: _selectedCountryName, selectedState: _selectedStateName);
              if (state != null) setState(() => _selectedStateName = state.name);
            }),
            const SizedBox(height: 20),
            _buildTextInput("City", "Your City", controller: _cityController),
            const SizedBox(height: 20),
            _buildTextInput("Address Line", "Street, house number etc", controller: _addressController),
            
            const SizedBox(height: 40),
            
            // --- Contacts Section ---
            _buildSectionHeader("Contacts"),
            const SizedBox(height: 16),
            _buildTextInput("Business Email", "you@example.com", controller: _emailController),
            const SizedBox(height: 20),
            _buildPhoneInputWithPicker("Business Phone Number", controller: _phoneController),          
            const SizedBox(height: 20),
            _buildTextInput("Website URL", "https://example.com", controller: _websiteController),

            const SizedBox(height: 40),

            // --- Social handles Section ---
            _buildSectionHeader("Social handles"),
            const SizedBox(height: 16),
            _buildTextInput("Instagram", "Your Instagram URL", controller: _instagramController),
            const SizedBox(height: 20),
            _buildTextInput("Facebook", "Your Facebook URL", controller: _facebookController),

            // Music platform links are entered in Step 2 (Music Business Details)
            
            const SizedBox(height: 40),
            
            // --- Means Identification Section ---
            _buildSectionHeader("Means Identification"),
            const SizedBox(height: 16),
            _buildFileUploadSection(),
            
            const SizedBox(height: 40),
            
            // --- Save Button ---
            _buildSubmitButton(context),
            const SizedBox(height: 40),
          ],
        ),
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
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF603814) : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: isActive ? const Color(0xFF603814) : const Color(0xFF777F84),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3C4042),
      ),
    );
  }

  Widget _buildTextInput(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown({required String label, required String value, String? flag, required VoidCallback onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
      const SizedBox(height: 8),
      GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCCCCCC))),
        child: Row(children: [
          if (flag != null) ...[Text(flag, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12)],
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021)))),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
        ]),
      )),
    ]);
  }

  Widget _buildPhoneInputWithPicker(String label, {required TextEditingController controller}) {
    final hasCountryCode = _selectedCountryCode.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
      const SizedBox(height: 8),
      Container(height: 49, padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCCCCCC))),
        child: Row(children: [
          GestureDetector(onTap: () async {
            final country = await CountryCodePickerSheet.show(context, selectedDialCode: _selectedCountryCode);
            if (country != null) setState(() { _selectedCountryCode = country.dialCode; _selectedCountryFlag = country.flag; });
          }, child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (hasCountryCode) ...[
              Text(_selectedCountryFlag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(_selectedCountryCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF241508))),
            ] else
              const Text('Code', style: TextStyle(fontSize: 16, color: Color(0xFFCCCCCC))),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF777F84)),
          ])),
          const SizedBox(width: 8),
          Expanded(child: TextFormField(controller: controller, keyboardType: TextInputType.phone, style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: 'Enter phone number', hintStyle: TextStyle(color: Color(0xFFCCCCCC))))),
        ]),
      ),
    ]);
  }

  Widget _buildFileUploadSection() {
    return InkWell(
      onTap: () async {
        final path = await pickSingleFilePath();
        if (path == null) return;
        setState(() => _identityDocumentLocalPath = path);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Document',
            style: TextStyle(color: Color(0xFF777F84), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF89858A)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 24, color: Color(0xFF777F84)),
                const SizedBox(height: 12),
                Text(
                  _identityDocumentLocalPath == null ? 'Browse Document' : 'Document selected',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'High resolution image\nPDF, JPG, PNG formats',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Color(0xFF777F84)),
                    ),
                    SizedBox(width: 20),
                    Text(
                      '200 x 200px\n20kb max',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Color(0xFF777F84)),
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

  bool _isValidUrl(String v) {
    final value = v.trim();
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  bool _validateStep1() {
    if (_selectedCountryName.isEmpty) {
      AppSnackbars.showError(context, 'Please select a country');
      return false;
    }
    if (_selectedStateName.isEmpty) {
      AppSnackbars.showError(context, 'Please select a state');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Please enter your city');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Please enter your address');
      return false;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackbars.showError(context, 'Please enter a valid email address');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Please enter a phone number');
      return false;
    }
    if (_identityDocumentLocalPath == null || _identityDocumentLocalPath!.isEmpty) {
      AppSnackbars.showError(context, 'Please upload your identity document');
      return false;
    }

    // Optional URLs: if provided, must be valid
    final website = _websiteController.text.trim();
    if (website.isNotEmpty && !_isValidUrl(website)) {
      AppSnackbars.showError(context, 'Please enter a valid website URL (include https://)');
      return false;
    }

    final instagram = _instagramController.text.trim();
    if (instagram.isNotEmpty && !_isValidUrl(instagram)) {
      AppSnackbars.showError(context, 'Please enter a valid Instagram URL (include https://)');
      return false;
    }

    final facebook = _facebookController.text.trim();
    if (facebook.isNotEmpty && !_isValidUrl(facebook)) {
      AppSnackbars.showError(context, 'Please enter a valid Facebook URL (include https://)');
      return false;
    }

    return true;
  }

  Widget _buildSubmitButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!_validateStep1()) return;

        final args = ModalRoute.of(context)?.settings.arguments;
        final draftFromArgs = (args is Map<String, dynamic>)
            ? BusinessRegistrationDraft.fromJson(args)
            : null;
        final selectedCategory = draftFromArgs?.categoryLabel ?? (args as String?) ?? 'Beauty';

        final draft = (draftFromArgs ?? BusinessRegistrationDraft(categoryLabel: selectedCategory))
          ..country = _selectedCountryName
          ..state = _selectedStateName
          ..city = _cityController.text.trim()
          ..address = _addressController.text.trim()
          ..businessEmail = _emailController.text.trim()
          ..businessPhoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}'
          ..websiteUrl = _websiteController.text.trim()
          ..instagram = _instagramController.text.trim()
          ..facebook = _facebookController.text.trim()
          ..youtube = null
          ..spotify = null
          ..identityDocumentPath = _identityDocumentLocalPath;

        // Map UI category labels to form routes
        // Business profiles now only use: afro_beauty_services (Beauty), school (Schools)
        // Art has been moved to Products
        final route = switch (selectedCategory) {
          'Beauty' => AppRoutes.businessBeautyForm,
          'Schools' => AppRoutes.businessSchoolsForm,
          _ => AppRoutes.businessBeautyForm,
        };

        // If we came in via legacy string-only args, we may not have categoryId/subcategoryId.
        // Force selection before continuing.
        if (draft.categoryId == null || draft.subcategoryId == null) {
          final catalog = await ref.read(allCategoriesProvider.future);
          if (!mounted) return;
          final all = catalog.categories;

          // Map UI category labels to backend category types
          // Business profiles now only use: afro_beauty_services, school
          // Art has been moved to Products
          List<CategoryNode> roots;
          switch (selectedCategory) {
            case 'Beauty':
              roots = all['afro_beauty_services'] ?? const [];
              break;
            case 'Schools':
              roots = all['school'] ?? const [];
              break;
            default:
              roots = all[selectedCategory.toLowerCase()] ?? const [];
          }

          final selectedNode = await showCategoryTreePickerSheet(
            context: context,
            title: 'Select Category',
            roots: roots,
          );
          if (selectedNode == null) return;

          draft
            ..categoryId = selectedNode.parentId ?? selectedNode.id
            ..subcategoryId = selectedNode.id;
        }

        Navigator.of(context).pushNamed(route, arguments: draft.toJson());
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: const Center(
          child: Text(
            'Save and Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}