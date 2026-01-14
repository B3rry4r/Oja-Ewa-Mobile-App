import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'location_data.dart';
import 'location_providers.dart';

/// Searchable Country Picker Bottom Sheet
/// Matches the app's InfoBottomSheet styling with search functionality
class CountryPickerSheet extends ConsumerStatefulWidget {
  const CountryPickerSheet({
    super.key,
    required this.selectedCountry,
    this.africanOnly = true,
  });

  final String? selectedCountry;
  final bool africanOnly;

  /// Shows the country picker and returns the selected country name
  static Future<Country?> show(
    BuildContext context, {
    String? selectedCountry,
    bool africanOnly = true,
  }) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(179),
      builder: (context) => CountryPickerSheet(
        selectedCountry: selectedCountry,
        africanOnly: africanOnly,
      ),
    );
  }

  @override
  ConsumerState<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends ConsumerState<CountryPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = widget.africanOnly
        ? ref.watch(africanCountriesProvider)
        : ref.watch(allCountriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(26),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF301C0A),
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: const Color(0xFF301C0A),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFDEDEDE), thickness: 0.5),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _buildSearchField(),
            ),

            // Country list
            Expanded(
              child: countriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load countries'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          widget.africanOnly ? africanCountriesProvider : allCountriesProvider,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (countries) {
                  final filtered = _searchQuery.isEmpty
                      ? countries
                      : countries.where((c) =>
                          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          c.code.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No countries found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: Color(0xFF777F84),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final country = filtered[index];
                      final isSelected = country.name == widget.selectedCountry;

                      return ListTile(
                        leading: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          country.name,
                          style: const TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: Color(0xFF1E2021),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF603814))
                            : null,
                        onTap: () => Navigator.of(context).pop(country),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Color(0xFF777F84)),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: Color(0xFF1E2021),
              ),
              decoration: const InputDecoration(
                hintText: 'Search country...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: Color(0xFFCCCCCC),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Color(0xFF777F84)),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }
}

/// Searchable State/Province Picker Bottom Sheet
class StatePickerSheet extends ConsumerStatefulWidget {
  const StatePickerSheet({
    super.key,
    required this.countryName,
    required this.selectedState,
  });

  final String countryName;
  final String? selectedState;

  /// Shows the state picker and returns the selected state name
  static Future<StateProvince?> show(
    BuildContext context, {
    required String countryName,
    String? selectedState,
  }) {
    return showModalBottomSheet<StateProvince>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(179),
      builder: (context) => StatePickerSheet(
        countryName: countryName,
        selectedState: selectedState,
      ),
    );
  }

  @override
  ConsumerState<StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends ConsumerState<StatePickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(statesProvider(widget.countryName));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(26),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select State',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF301C0A),
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: const Color(0xFF301C0A),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFDEDEDE), thickness: 0.5),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _buildSearchField(),
            ),

            // State list
            Expanded(
              child: statesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load states'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(statesProvider(widget.countryName)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (states) {
                  final filtered = _searchQuery.isEmpty
                      ? states
                      : states.where((s) =>
                          s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No states found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: Color(0xFF777F84),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final state = filtered[index];
                      final isSelected = state.name == widget.selectedState;

                      return ListTile(
                        title: Text(
                          state.name,
                          style: const TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: Color(0xFF1E2021),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF603814))
                            : null,
                        onTap: () => Navigator.of(context).pop(state),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Color(0xFF777F84)),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: Color(0xFF1E2021),
              ),
              decoration: const InputDecoration(
                hintText: 'Search state...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: Color(0xFFCCCCCC),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Color(0xFF777F84)),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }
}

/// Searchable Country Code Picker Bottom Sheet for phone numbers
class CountryCodePickerSheet extends ConsumerStatefulWidget {
  const CountryCodePickerSheet({
    super.key,
    required this.selectedDialCode,
    this.africanOnly = true,
  });

  final String? selectedDialCode;
  final bool africanOnly;

  /// Shows the country code picker and returns the selected country
  static Future<Country?> show(
    BuildContext context, {
    String? selectedDialCode,
    bool africanOnly = true,
  }) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(179),
      builder: (context) => CountryCodePickerSheet(
        selectedDialCode: selectedDialCode,
        africanOnly: africanOnly,
      ),
    );
  }

  @override
  ConsumerState<CountryCodePickerSheet> createState() => _CountryCodePickerSheetState();
}

class _CountryCodePickerSheetState extends ConsumerState<CountryCodePickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = widget.africanOnly
        ? ref.watch(africanCountriesProvider)
        : ref.watch(allCountriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(26),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country Code',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF301C0A),
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: const Color(0xFF301C0A),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFDEDEDE), thickness: 0.5),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _buildSearchField(),
            ),

            // Country code list
            Expanded(
              child: countriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load country codes'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          widget.africanOnly ? africanCountriesProvider : allCountriesProvider,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (countries) {
                  final filtered = _searchQuery.isEmpty
                      ? countries
                      : countries.where((c) =>
                          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          c.dialCode.contains(_searchQuery) ||
                          c.code.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No country codes found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: Color(0xFF777F84),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final country = filtered[index];
                      final isSelected = country.dialCode == widget.selectedDialCode;

                      return ListTile(
                        leading: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          country.name,
                          style: const TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: Color(0xFF1E2021),
                          ),
                        ),
                        subtitle: Text(
                          country.dialCode,
                          style: const TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF603814),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF603814))
                            : null,
                        onTap: () => Navigator.of(context).pop(country),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Color(0xFF777F84)),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: Color(0xFF1E2021),
              ),
              decoration: const InputDecoration(
                hintText: 'Search country or code...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: Color(0xFFCCCCCC),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Color(0xFF777F84)),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }
}
