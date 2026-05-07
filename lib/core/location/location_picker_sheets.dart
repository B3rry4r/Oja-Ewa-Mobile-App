import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
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
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
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
    final colors = context.appColors;
    final countriesAsync = widget.africanOnly
        ? ref.watch(africanCountriesProvider)
        : ref.watch(allCountriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.border)),
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
                  color: colors.borderStrong,
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
                  Text(
                    'Select Country',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: colors.textPrimary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(color: colors.border, thickness: 0.5),

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
                      Text(
                        'Failed to load countries',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          widget.africanOnly
                              ? africanCountriesProvider
                              : allCountriesProvider,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (countries) {
                  final filtered = _searchQuery.isEmpty
                      ? countries
                      : countries
                            .where(
                              (c) =>
                                  c.name.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  c.code.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No countries found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: colors.textTertiary,
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
                          style: TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colors.accent)
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
    final colors = context.appColors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: colors.textTertiary),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: colors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colors.textTertiary),
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
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
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
    final colors = context.appColors;
    final statesAsync = ref.watch(statesProvider(widget.countryName));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.border)),
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
                  color: colors.borderStrong,
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
                  Text(
                    'Select State',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: colors.textPrimary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(color: colors.border, thickness: 0.5),

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
                      Text(
                        'Failed to load states',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(statesProvider(widget.countryName)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (states) {
                  final filtered = _searchQuery.isEmpty
                      ? states
                      : states
                            .where(
                              (s) => s.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No states found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: colors.textTertiary,
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
                          style: TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colors.accent)
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
    final colors = context.appColors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: colors.textTertiary),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search state...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: colors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colors.textTertiary),
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

/// Searchable City Picker Bottom Sheet
class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet({
    super.key,
    required this.countryName,
    required this.stateName,
    required this.selectedCity,
  });

  final String countryName;
  final String stateName;
  final String? selectedCity;

  /// Shows the city picker and returns the selected city name
  static Future<String?> show(
    BuildContext context, {
    required String countryName,
    required String stateName,
    String? selectedCity,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
      builder: (context) => CityPickerSheet(
        countryName: countryName,
        stateName: stateName,
        selectedCity: selectedCity,
      ),
    );
  }

  @override
  ConsumerState<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final citiesAsync = ref.watch(citiesProvider((
      country: widget.countryName,
      state: widget.stateName,
    )));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.border)),
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
                  color: colors.borderStrong,
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
                  Text(
                    'Select City/LGA',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: colors.textPrimary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(color: colors.border, thickness: 0.5),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _buildSearchField(),
            ),

            // City list
            Expanded(
              child: citiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load cities',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(citiesProvider((
                          country: widget.countryName,
                          state: widget.stateName,
                        ))),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (cities) {
                  final filtered = _searchQuery.isEmpty
                      ? cities
                      : cities
                            .where(
                              (c) => c.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No cities found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: colors.textTertiary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final city = filtered[index];
                      final isSelected = city == widget.selectedCity;

                      return ListTile(
                        title: Text(
                          city,
                          style: TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colors.accent)
                            : null,
                        onTap: () => Navigator.of(context).pop(city),
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
    final colors = context.appColors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: colors.textTertiary),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: colors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colors.textTertiary),
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
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
      builder: (context) => CountryCodePickerSheet(
        selectedDialCode: selectedDialCode,
        africanOnly: africanOnly,
      ),
    );
  }

  @override
  ConsumerState<CountryCodePickerSheet> createState() =>
      _CountryCodePickerSheetState();
}

class _CountryCodePickerSheetState
    extends ConsumerState<CountryCodePickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final countriesAsync = widget.africanOnly
        ? ref.watch(africanCountriesProvider)
        : ref.watch(allCountriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.border)),
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
                  color: colors.borderStrong,
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
                  Text(
                    'Select Country Code',
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  HeaderIconButton(
                    asset: AppIcons.back,
                    iconColor: colors.textPrimary,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(color: colors.border, thickness: 0.5),

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
                      Text(
                        'Failed to load country codes',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          widget.africanOnly
                              ? africanCountriesProvider
                              : allCountriesProvider,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (countries) {
                  final filtered = _searchQuery.isEmpty
                      ? countries
                      : countries
                            .where(
                              (c) =>
                                  c.name.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  c.dialCode.contains(_searchQuery) ||
                                  c.code.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No country codes found',
                        style: TextStyle(
                          fontFamily: 'Campton',
                          color: colors.textTertiary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final country = filtered[index];
                      final isSelected =
                          country.dialCode == widget.selectedDialCode;

                      return ListTile(
                        leading: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          country.dialCode,
                          style: TextStyle(
                            fontFamily: 'Campton',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.accent,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colors.accent)
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
    final colors = context.appColors;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: colors.textTertiary),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search country or code...',
                hintStyle: TextStyle(
                  fontFamily: 'Campton',
                  color: colors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colors.textTertiary),
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
