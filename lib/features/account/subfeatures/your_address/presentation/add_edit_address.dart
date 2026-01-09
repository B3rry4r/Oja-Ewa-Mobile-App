// add_edit_address.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../domain/address.dart';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({super.key, this.initialAddress});

  /// If provided, the screen is in "edit" mode and fields are prefilled.
  final Address? initialAddress;

  bool get isEdit => initialAddress != null;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _postCode;
  late final TextEditingController _addressLine;

  bool _makeDefault = true;

  @override
  void initState() {
    super.initState();

    final a = widget.initialAddress;
    _fullName = TextEditingController(text: a?.fullName ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _postCode = TextEditingController(text: a?.postCode ?? '');
    _addressLine = TextEditingController(text: a?.addressLine ?? '');
    _makeDefault = a?.isDefault ?? true;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _city.dispose();
    _postCode.dispose();
    _addressLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Edit Address' : 'Add Address';
    final buttonText = widget.isEdit ? 'Save Changes' : 'Save New Address';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              AppHeader(
                backgroundColor: const Color(0xFFFFF8F1),
                iconColor: const Color(0xFF241508),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: Color(0xFF241508),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildFormFields(context, buttonText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, String buttonText) {
    final a = widget.initialAddress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildDropdownField(
            label: 'Country',
            value: a?.country ?? 'Nigeria',
            hasDropdown: true,
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Full Name',
            controller: _fullName,
            hintText: 'Your Name here',
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Phone Number',
            controller: _phone,
            hintText: '08102718764',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          _buildDropdownField(
            label: 'State',
            value: a?.state ?? 'FCT',
            hasDropdown: true,
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'City',
            controller: _city,
            hintText: 'Your City',
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Post/Zip Code',
            controller: _postCode,
            hintText: '900187',
          ),
          const SizedBox(height: 24),

          _buildTextField(
            label: 'Address Line',
            controller: _addressLine,
            hintText: 'Street, house number etc',
          ),
          const SizedBox(height: 40),

          _buildDefaultAddressToggle(),
          const SizedBox(height: 40),

          _buildSaveButton(context, buttonText),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required bool hasDropdown,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    color: Color(0xFF1E2021),
                  ),
                ),
                if (hasDropdown)
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFF1E2021),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  color: Color(0xFFCCCCCC),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddressToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Make Default Address',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            color: Color(0xFF241508),
          ),
        ),
        Switch(
          value: _makeDefault,
          activeColor: const Color(0xFFFDAF40),
          onChanged: (v) => setState(() => _makeDefault = v),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // TODO: Persist later.
            Navigator.of(context).maybePop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
