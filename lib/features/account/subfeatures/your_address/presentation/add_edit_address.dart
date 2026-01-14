// add_edit_address.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';

import '../domain/address.dart';
import 'controllers/address_controller.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  const AddEditAddressScreen({super.key, this.initialAddress});

  /// If provided, the screen is in "edit" mode and fields are prefilled.
  final Address? initialAddress;

  bool get isEdit => initialAddress != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _postCode;
  late final TextEditingController _addressLine;

  bool _makeDefault = false;
  
  // Location selections
  String _selectedCountryName = 'Nigeria';
  String _selectedCountryFlag = '🇳🇬';
  String _selectedStateName = '';
  String _selectedCountryCode = '+234';

  @override
  void initState() {
    super.initState();

    final a = widget.initialAddress;
    _fullName = TextEditingController(text: a?.fullName ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _postCode = TextEditingController(text: a?.postCode ?? '');
    _addressLine = TextEditingController(text: a?.addressLine ?? '');
    _makeDefault = a?.isDefault ?? false;
    
    // Initialize location from existing address
    if (a != null) {
      _selectedCountryName = a.country ?? 'Nigeria';
      _selectedStateName = a.state ?? '';
    }
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
    final actions = ref.watch(addressActionsProvider);

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildLocationDropdown(
                      label: 'Country',
                      value: _selectedCountryName,
                      flag: _selectedCountryFlag,
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
                            _selectedStateName = ''; // Reset state when country changes
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildLocationDropdown(
                      label: 'State',
                      value: _selectedStateName.isEmpty ? 'Select State' : _selectedStateName,
                      onTap: () async {
                        final state = await StatePickerSheet.show(
                          context,
                          countryName: _selectedCountryName,
                          selectedState: _selectedStateName,
                        );
                        if (state != null) {
                          setState(() {
                            _selectedStateName = state.name;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(label: 'City', controller: _city),
                    const SizedBox(height: 24),
                    _buildTextField(label: 'Post/Zip Code', controller: _postCode),
                    const SizedBox(height: 24),
                    _buildTextField(label: 'Full Name', controller: _fullName),
                    const SizedBox(height: 24),
                    _buildTextField(label: 'Phone Number', controller: _phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 24),
                    _buildTextField(label: 'Address Line', controller: _addressLine),
                    const SizedBox(height: 40),
                    _buildDefaultAddressToggle(),
                    const SizedBox(height: 24),
                    if (widget.isEdit) _buildDeleteButton(context, actions),
                    const SizedBox(height: 16),
                    _buildSaveButton(context, actions, buttonText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
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
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(8),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF241508),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Color(0xFF1E2021),
                ),
              ],
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

  Widget _buildSaveButton(BuildContext context, AsyncValue<void> actions, String text) {
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
          onTap: actions.isLoading
              ? null
              : () async {
                  final a = Address(
                    id: widget.initialAddress?.id ?? 0,
                    fullName: _fullName.text.trim(),
                    phone: _phone.text.trim(),
                    country: _selectedCountryName,
                    state: _selectedStateName,
                    city: _city.text.trim(),
                    postCode: _postCode.text.trim(),
                    addressLine: _addressLine.text.trim(),
                    isDefault: _makeDefault,
                  );

                  if (widget.isEdit) {
                    await ref.read(addressActionsProvider.notifier).updateAddress(a);
                  } else {
                    await ref.read(addressActionsProvider.notifier).create(a);
                  }

                  if (!mounted) return;
                  Navigator.of(context).pop(true);
                },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: actions.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
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

  Widget _buildDeleteButton(BuildContext context, AsyncValue<void> actions) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7E5E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: actions.isLoading
              ? null
              : () async {
                  final id = widget.initialAddress!.id;
                  await ref.read(addressActionsProvider.notifier).delete(id);
                  if (!mounted) return;
                  Navigator.of(context).pop(true);
                },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Delete Address',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2021),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
