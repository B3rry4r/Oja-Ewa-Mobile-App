// add_edit_address.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';

import '../domain/address.dart';
import 'controllers/address_controller.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  const AddEditAddressScreen({super.key, this.initialAddress});

  /// If provided, the screen is in "edit" mode and fields are prefilled.
  final Address? initialAddress;

  bool get isEdit => initialAddress != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _postCode;
  late final TextEditingController _addressLine;

  bool _makeDefault = false;

  // Location selections
  // Location selections - empty by default (populated from existing address if editing)
  String _selectedCountryName = '';
  String _selectedCountryFlag = '';
  String _selectedStateName = '';

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
      _selectedCountryName = a.country;
      _selectedStateName = a.state;
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

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : null,
        ),
      );
  }

  /// Returns the name of the first missing required field, or `null` if valid.
  String? _firstMissingField() {
    if (_selectedCountryName.trim().isEmpty) return 'Country';
    if (_selectedStateName.trim().isEmpty) return 'State';
    if (_city.text.trim().isEmpty) return 'City/LGA';
    if (_fullName.text.trim().isEmpty) return 'Full Name';
    if (_phone.text.trim().isEmpty) return 'Phone Number';
    if (_addressLine.text.trim().isEmpty) return 'Address Line';
    if (_postCode.text.trim().isEmpty) return 'Post/Zip Code';
    return null;
  }

  Future<void> _onSave() async {
    final missing = _firstMissingField();
    if (missing != null) {
      _showSnack('Please enter $missing.', isError: true);
      return;
    }

    final a = Address(
      id: widget.initialAddress?.id ?? 0,
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim(),
      country: _selectedCountryName.trim(),
      state: _selectedStateName.trim(),
      city: _city.text.trim(),
      postCode: _postCode.text.trim(),
      addressLine: _addressLine.text.trim(),
      isDefault: _makeDefault,
    );

    final notifier = ref.read(addressActionsProvider.notifier);
    final success = widget.isEdit
        ? await notifier.updateAddress(a)
        : await notifier.create(a);

    if (!mounted) return;

    if (success) {
      _showSnack(widget.isEdit ? 'Address updated.' : 'Address saved.');
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(addressActionsProvider).error;
      _showSnack(
        'Could not save address. ${error ?? 'Please try again.'}',
        isError: true,
      );
    }
  }

  Future<void> _onDelete() async {
    final id = widget.initialAddress!.id;
    final success = await ref.read(addressActionsProvider.notifier).delete(id);

    if (!mounted) return;

    if (success) {
      _showSnack('Address deleted.');
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(addressActionsProvider).error;
      _showSnack(
        'Could not delete address. ${error ?? 'Please try again.'}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = widget.isEdit ? 'Edit Address' : 'Add Address';
    final buttonText = widget.isEdit ? 'Save Changes' : 'Save New Address';
    final actions = ref.watch(addressActionsProvider);

    return AppPageScaffold(
      title: title,
      scrollable: true,
      child: Column(
        children: [
          const SizedBox(height: 8),
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
                  _selectedStateName = '';
                });
              }
            },
          ),
          const SizedBox(height: 24),
          _buildLocationDropdown(
            label: 'State',
            value: _selectedStateName.isEmpty
                ? 'Select State'
                : _selectedStateName,
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
          _buildLocationDropdown(
            label: 'City/LGA',
            value: _city.text.isEmpty ? 'Select City/LGA' : _city.text,
            onTap: () async {
              if (_selectedStateName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a state first')),
                );
                return;
              }
              final city = await CityPickerSheet.show(
                context,
                countryName: _selectedCountryName,
                stateName: _selectedStateName,
                selectedCity: _city.text,
              );
              if (city != null) {
                setState(() {
                  _city.text = city;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          _buildTextField(label: 'Post/Zip Code', controller: _postCode),
          const SizedBox(height: 24),
          _buildTextField(label: 'Full Name', controller: _fullName),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Phone Number',
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          _buildTextField(label: 'Address Line', controller: _addressLine),
          const SizedBox(height: 40),
          _buildDefaultAddressToggle(),
          const SizedBox(height: 24),
          if (widget.isEdit) _buildDeleteButton(context, actions),
          const SizedBox(height: 16),
          _buildSaveButton(context, actions, buttonText),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(border: InputBorder.none),
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
          style: TextStyle(
            fontSize: 14,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: colors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddressToggle() {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Make Default Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        Switch(
          value: _makeDefault,
          activeThumbColor: colors.accent,
          onChanged: (v) => setState(() => _makeDefault = v),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AsyncValue<void> actions,
    String text,
  ) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: actions.isLoading ? null : () => _onSave(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: actions.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onAccent,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onAccent,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, AsyncValue<void> actions) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: actions.isLoading ? null : () => _onDelete(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Delete Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
