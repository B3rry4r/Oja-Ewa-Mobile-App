// filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/product/domain/product_filters.dart';
import 'package:ojaewa/features/product/presentation/controllers/product_filters_controller.dart';

class FilterSheet extends ConsumerStatefulWidget {
  /// Callback when filters are applied
  final Function(SelectedFilters filters)? onApplyFilters;

  /// Callback when filters are cleared
  final VoidCallback? onClearFilters;

  const FilterSheet({
    super.key,
    this.onApplyFilters,
    this.onClearFilters,
  });

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  // Local filter state (before applying)
  String? _selectedGender;
  String? _selectedStyle;
  String? _selectedTribe;
  RangeValues? _priceRange;

  @override
  void initState() {
    super.initState();
    // Initialize with current selected filters
    final currentFilters = ref.read(selectedFiltersProvider);
    _selectedGender = currentFilters.gender;
    _selectedStyle = currentFilters.style;
    _selectedTribe = currentFilters.tribe;
    if (currentFilters.priceMin != null || currentFilters.priceMax != null) {
      _priceRange = RangeValues(
        currentFilters.priceMin ?? 0,
        currentFilters.priceMax ?? 10000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtersAsync = ref.watch(availableFiltersProvider);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: SafeArea(
        child: Column(
          children: [
            // Spacer to push content to bottom
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Filter sheet content
            filtersAsync.when(
              loading: () => _buildLoadingSheet(),
              error: (_, __) => _buildErrorSheet(),
              data: (filters) => _buildFilterSheet(filters),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorSheet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Center(child: Text('Failed to load filters')),
    );
  }

  Widget _buildFilterSheet(ProductFilters filters) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            _buildHeader(),

            // Gender filter section
            if (filters.genders.isNotEmpty) ...[
              _buildSectionTitle('Gender'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.genders,
                selected: _selectedGender,
                onSelected: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 24),
            ],

            // Style filter section
            if (filters.styles.isNotEmpty) ...[
              _buildSectionTitle('Style'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.styles,
                selected: _selectedStyle,
                onSelected: (value) => setState(() => _selectedStyle = value),
              ),
              const SizedBox(height: 24),
            ],

            // Tribe filter section
            if (filters.tribes.isNotEmpty) ...[
              _buildSectionTitle('Tribe'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.tribes,
                selected: _selectedTribe,
                onSelected: (value) => setState(() => _selectedTribe = value),
              ),
              const SizedBox(height: 24),
            ],

            // Price range filter
            _buildSectionTitle('Price Range'),
            const SizedBox(height: 8),
            _buildPriceRangeFilter(filters.priceRange),
            const SizedBox(height: 40),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildChipFilters({
    required List<String> options,
    required String? selected,
    required Function(String?) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selected == option;
          return GestureDetector(
            onTap: () => onSelected(isSelected ? null : option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFFA15E22) : const Color(0xFFCCCCCC),
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: isSelected ? Colors.white : const Color(0xFF1E2021),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeFilter(PriceRange priceRange) {
    final currentRange = _priceRange ?? RangeValues(priceRange.min, priceRange.max);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'N${currentRange.start.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFF1E2021),
                ),
              ),
              Text(
                'N${currentRange.end.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFF1E2021),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: currentRange,
            min: priceRange.min,
            max: priceRange.max,
            activeColor: const Color(0xFFA15E22),
            inactiveColor: const Color(0xFFE0E0E0),
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          const Text(
            'Filter By',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF301C0A),
            ),
          ),

          // Close button
          HeaderIconButton(
            asset: AppIcons.back,
            iconColor: const Color(0xFF301C0A),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w600,
          color: Color(0xFF301C0A),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Clear Filters button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedGender = null;
                  _selectedStyle = null;
                  _selectedTribe = null;
                  _priceRange = null;
                });
                ref.read(selectedFiltersProvider.notifier).clearFilters();
                widget.onClearFilters?.call();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: const BorderSide(color: Color(0xFFFDAF40)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDAF40),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Show Results button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters to the provider
                final filters = SelectedFilters(
                  gender: _selectedGender,
                  style: _selectedStyle,
                  tribe: _selectedTribe,
                  priceMin: _priceRange?.start,
                  priceMax: _priceRange?.end,
                  sortBy: ref.read(selectedFiltersProvider).sortBy, // Preserve sort
                );
                
                ref.read(selectedFiltersProvider.notifier).applyFilters(
                  gender: _selectedGender,
                  style: _selectedStyle,
                  tribe: _selectedTribe,
                  priceMin: _priceRange?.start,
                  priceMax: _priceRange?.end,
                );

                widget.onApplyFilters?.call(filters);
                Navigator.of(context).pop(filters);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: const Color(0xFFFDAF40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFFDAF40).withOpacity(0.5),
              ),
              child: const Text(
                'Show Results',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFBF5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
