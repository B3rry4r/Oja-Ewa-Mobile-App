import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/domain/business_profile_payload.dart';
import 'package:ojaewa/features/account/subfeatures/show_your_business/presentation/controllers/business_management_controller.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

class EditBusinessScreen extends ConsumerStatefulWidget {
  const EditBusinessScreen({super.key});

  @override
  ConsumerState<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  String _selectedCountryName = 'Nigeria';
  bool _initialized = false;

  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _websiteController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productListController = TextEditingController();
  String _selectedCountryFlag = '🇳🇬';
  String _selectedStateName = 'FCT';
  String _selectedCountryCode = '+234';
  
  // File upload
  String? _businessLogoPath;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final businessId = (args is Map ? args['businessId'] : null) as int?;

    final businessAsync = businessId == null ? null : ref.watch(businessByIdProvider(businessId));

    // Populate controllers once
    businessAsync?.whenOrNull(
      data: (res) {
        if (_initialized) return;
        final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;
        _selectedCountryName = (data['country'] as String?) ?? _selectedCountryName;
        _selectedStateName = (data['state'] as String?) ?? _selectedStateName;
        _cityController.text = (data['city'] as String?) ?? '';
        _addressController.text = (data['address'] as String?) ?? '';
        _emailController.text = (data['business_email'] as String?) ?? '';
        _phoneController.text = (data['business_phone_number'] as String?) ?? '';
        _instagramController.text = (data['instagram'] as String?) ?? '';
        _facebookController.text = (data['facebook'] as String?) ?? '';
        _websiteController.text = (data['website_url'] as String?) ?? '';
        _businessNameController.text = (data['business_name'] as String?) ?? '';
        _descriptionController.text = (data['business_description'] as String?) ?? '';
        _productListController.text = (data['product_list'] as String?) ?? '';
        _initialized = true;
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      body: Column(
        children: [
          const AppHeader(
            backgroundColor: Color(0xFFFFF8F1),
            iconColor: Color(0xFF241508),
            title: Text(
              'Edit Business',
              style: TextStyle(
                color: Color(0xFF241508),
                fontSize: 22,
                fontFamily: 'Campton',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Business Location'),
                  const SizedBox(height: 16),
                  _buildLocationDropdown(label: 'Country', value: _selectedCountryName, flag: _selectedCountryFlag, onTap: () async {
                    final country = await CountryPickerSheet.show(context, selectedCountry: _selectedCountryName);
                    if (country != null) setState(() { _selectedCountryName = country.name; _selectedCountryFlag = country.flag; _selectedCountryCode = country.dialCode; _selectedStateName = ''; });
                  }),
                  const SizedBox(height: 16),
                  _buildLocationDropdown(label: 'State', value: _selectedStateName.isEmpty ? 'Select State' : _selectedStateName, onTap: () async {
                    final state = await StatePickerSheet.show(context, countryName: _selectedCountryName, selectedState: _selectedStateName);
                    if (state != null) setState(() => _selectedStateName = state.name);
                  }),
                  const SizedBox(height: 16),
                  _buildTextField('City', 'Your City', controller: _cityController),
                  const SizedBox(height: 16),
                  _buildTextField('Address Line', 'Street, house number etc', controller: _addressController),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Mobiles'),
                  const SizedBox(height: 16),
                  _buildTextField('Business Email', 'sanusimot@gmail.com', controller: _emailController),
                  const SizedBox(height: 16),
                  _buildPhoneInputWithPicker(),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Social handles'),
                  const SizedBox(height: 16),
                  _buildTextField('Instagram', 'Your Instagram URL', controller: _instagramController),
                  const SizedBox(height: 16),
                  _buildTextField('Facebook', 'Your Facebook URL', controller: _facebookController),
                  const SizedBox(height: 16),
                  _buildTextField('Website URL', 'Website URL', controller: _websiteController),

                  const SizedBox(height: 32),
                  _buildSectionHeader('About Business'),
                  const SizedBox(height: 16),
                  _buildTextField('Business Name', 'Business Name', controller: _businessNameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Description',
                    'Share details of your experience',
                    maxLines: 4,
                    helperText: '100 characters required',
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Product List',
                    'List your products here',
                    maxLines: 4,
                    controller: _productListController,
                  ),

                  const SizedBox(height: 32),
                  _buildLogoSection(),

                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3C4042),
        fontFamily: 'Campton',
      ),
    );
  }

  Widget _buildTextField(
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
          style: const TextStyle(
            color: Color(0xFF777F84),
            fontSize: 14,
            fontFamily: 'Campton',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              helperText,
              style: const TextStyle(color: Color(0xFF595F63), fontSize: 10),
            ),
          ),
        ],
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
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
        ]),
      )),
    ]);
  }

  Widget _buildPhoneInputWithPicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Business Phone Number', style: TextStyle(color: Color(0xFF777F84), fontSize: 14)),
      const SizedBox(height: 8),
      Container(height: 49, padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCCCCCC))),
        child: Row(children: [
          GestureDetector(onTap: () async {
            final country = await CountryCodePickerSheet.show(context, selectedDialCode: _selectedCountryCode);
            if (country != null) setState(() { _selectedCountryCode = country.dialCode; _selectedCountryFlag = country.flag; });
          }, child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_selectedCountryFlag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(_selectedCountryCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF241508))),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF777F84)),
          ])),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter phone number',
                hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Phone Number',
          style: TextStyle(color: Color(0xFF777F84), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: const Row(
            children: [
              Icon(Icons.flag, size: 20),
              SizedBox(width: 8),
              Text(
                '+234',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '8167654354',
                  style: TextStyle(fontSize: 16, color: Color(0xFFCCCCCC)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    final hasFile = _businessLogoPath != null && _businessLogoPath!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Business Logo'),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final path = await pickSingleFilePath();
            if (path != null) setState(() => _businessLogoPath = path);
          },
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: hasFile ? const Color(0xFF4CAF50) : const Color(0xFF89858A)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 24,
                  color: hasFile ? const Color(0xFF4CAF50) : const Color(0xFF777F84),
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile ? 'Logo selected' : 'Browse Document',
                  style: TextStyle(
                    fontSize: 16,
                    color: hasFile ? const Color(0xFF4CAF50) : const Color(0xFF1E2021),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () async {
        final args = ModalRoute.of(context)?.settings.arguments;
        final businessId = (args is Map ? args['businessId'] : null) as int?;
        if (businessId == null) return;

        // Fetch current to get required immutable fields (category/offering_type)
        final res = await ref.read(businessByIdProvider(businessId).future);
        final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;
        final category = (data['category'] as String?) ?? '';
        final offeringType = (data['offering_type'] as String?) ?? '';

        final payload = BusinessProfilePayload(
          category: category,
          categoryId: (data['category_id'] as num?)?.toInt() ?? 0,
          subcategoryId: (data['subcategory_id'] as num?)?.toInt() ?? 0,
          country: _selectedCountryName,
          state: _selectedStateName,
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          businessEmail: _emailController.text.trim(),
          businessPhoneNumber: _phoneController.text.trim(),
          websiteUrl: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          instagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
          facebook: _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
          businessName: _businessNameController.text.trim(),
          businessDescription: _descriptionController.text.trim(),
          offeringType: offeringType,
          productList: const [],
          serviceList: const [],
          professionalTitle: data['professional_title'] as String?,
          schoolType: data['school_type'] as String?,
          schoolBiography: data['school_biography'] as String?,
          classesOffered: const [],
          musicCategory: data['music_category'] as String?,
          youtube: data['youtube'] as String?,
          spotify: data['spotify'] as String?,
        );

        try {
          await ref.read(businessManagementActionsProvider.notifier).updateBusiness(businessId, payload);
          if (!context.mounted) return;
          AppSnackbars.showSuccess(context, 'Business updated');
          Navigator.of(context).pop();
        } catch (e) {
          if (!context.mounted) return;
          AppSnackbars.showError(context, UiErrorMessage.from(e));
        }
      },
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
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Save Changes',
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
