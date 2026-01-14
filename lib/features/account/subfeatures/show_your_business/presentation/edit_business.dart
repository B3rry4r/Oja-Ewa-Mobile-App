import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';

class EditBusinessScreen extends ConsumerStatefulWidget {
  const EditBusinessScreen({super.key});

  @override
  ConsumerState<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  String _selectedCountryName = 'Nigeria';
  String _selectedCountryFlag = '🇳🇬';
  String _selectedStateName = 'FCT';
  String _selectedCountryCode = '+234';

  @override
  Widget build(BuildContext context) {
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
                  _buildTextField('City', 'Your City'),
                  const SizedBox(height: 16),
                  _buildTextField('Address Line', 'Street, house number etc'),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Mobiles'),
                  const SizedBox(height: 16),
                  _buildTextField('Business Email', 'sanusimot@gmail.com'),
                  const SizedBox(height: 16),
                  _buildPhoneInputWithPicker(),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Social handles'),
                  const SizedBox(height: 16),
                  _buildTextField('Instagram', 'Your Instagram URL'),
                  const SizedBox(height: 16),
                  _buildTextField('Facebook', 'Your Facebook URL'),
                  const SizedBox(height: 16),
                  _buildTextField('Website URL', 'sanusimot@gmail.com'),

                  const SizedBox(height: 32),
                  _buildSectionHeader('About Business'),
                  const SizedBox(height: 16),
                  _buildTextField('Business Name', 'Your City'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Description',
                    'Share details of your experience',
                    maxLines: 4,
                    helperText: '100 characters required',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Product List',
                    'List your products here',
                    maxLines: 4,
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
          const Expanded(child: TextField(keyboardType: TextInputType.phone, style: TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
            decoration: InputDecoration(border: InputBorder.none, hintText: 'Enter phone number', hintStyle: TextStyle(color: Color(0xFFCCCCCC))))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Business Logo'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFF89858A)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 24,
                color: Color(0xFF777F84),
              ),
              SizedBox(height: 12),
              Text(
                'Browse Document',
                style: TextStyle(fontSize: 16, color: Color(0xFF1E2021)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withOpacity(0.4),
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
