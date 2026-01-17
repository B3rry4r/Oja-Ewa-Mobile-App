// filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
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

  /// Styles to exclude from selection
  final Set<String> excludeStyles;

  /// Category type to show relevant filters:
  /// - textiles: all filters including fabric_type
  /// - shoes_bags: all filters except fabric_type
  /// - afro_beauty_products, art: price only
  final String? categoryType;

  const FilterSheet({
    super.key,
    this.onApplyFilters,
    this.onClearFilters,
    this.excludeStyles = const {},
    this.categoryType,
  });

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  // Local filter state (before applying)
  String? _selectedGender;
  String? _selectedStyle;
  String? _selectedTribe;
  String? _selectedFabricType;
  RangeValues? _priceRange;

  @override
  void initState() {
    super.initState();
    // Initialize with current selected filters
    final currentFilters = ref.read(selectedFiltersProvider);
    _selectedGender = currentFilters.gender;
    _selectedStyle = currentFilters.style;
    _selectedTribe = currentFilters.tribe;
    _selectedFabricType = currentFilters.fabricType;
    if (currentFilters.priceMin != null || currentFilters.priceMax != null) {
      _priceRange = RangeValues(
        currentFilters.priceMin ?? 0,
        currentFilters.priceMax ?? 10000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use hardcoded default filters - no API call needed
    final filters = ProductFilters.defaults;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
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
            // Filter sheet content - use defaults directly, no async needed
            _buildFilterSheet(filters),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet(ProductFilters filters) {
    // Determine which filters to show based on category type
    // - textiles: all filters including fabric_type
    // - shoes_bags: all filters except fabric_type
    // - afro_beauty_products, art: price only (no extended fields)
    final type = widget.categoryType?.toLowerCase() ?? 'textiles';
    final showExtendedFilters = type == 'textiles' || type == 'shoes_bags';
    final showFabricType = type == 'textiles';

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

            // Gender filter section (textiles & shoes_bags only)
            if (showExtendedFilters && filters.genders.isNotEmpty) ...[
              _buildSectionTitle('Gender'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.genders,
                selected: _selectedGender,
                onSelected: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 24),
            ],

            // Style filter section (textiles & shoes_bags only)
            if (showExtendedFilters && filters.styles.isNotEmpty) ...[
              _buildSectionTitle('Style'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.styles
                    .where((s) => !widget.excludeStyles.contains(s))
                    .toList(),
                selected: _selectedStyle,
                onSelected: (value) => setState(() => _selectedStyle = value),
              ),
              const SizedBox(height: 24),
            ],

            // Tribe filter section (textiles & shoes_bags only)
            if (showExtendedFilters && filters.tribes.isNotEmpty) ...[
              _buildSectionTitle('Tribe'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.tribes,
                selected: _selectedTribe,
                onSelected: (value) => setState(() => _selectedTribe = value),
              ),
              const SizedBox(height: 24),
            ],

            // Fabric Type filter section (textiles only)
            if (showFabricType && filters.fabricTypes.isNotEmpty) ...[
              _buildSectionTitle('Fabric Type'),
              const SizedBox(height: 8),
              _buildChipFilters(
                options: filters.fabricTypes,
                selected: _selectedFabricType,
                onSelected: (value) =>
                    setState(() => _selectedFabricType = value),
              ),
              const SizedBox(height: 24),
            ],

            // Price range filter (all categories)
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
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFA15E22)
                      : const Color(0xFFCCCCCC),
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
    final currentRange =
        _priceRange ?? RangeValues(priceRange.min, priceRange.max);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatPrice(currentRange.start.toInt()),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFF1E2021),
                ),
              ),
              Text(
                formatPrice(currentRange.end.toInt()),
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
                  _selectedFabricType = null;
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
                  fabricType: _selectedFabricType,
                  priceMin: _priceRange?.start,
                  priceMax: _priceRange?.end,
                  sortBy: ref
                      .read(selectedFiltersProvider)
                      .sortBy, // Preserve sort
                );

                ref
                    .read(selectedFiltersProvider.notifier)
                    .applyFilters(
                      gender: _selectedGender,
                      style: _selectedStyle,
                      tribe: _selectedTribe,
                      fabricType: _selectedFabricType,
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
                shadowColor: const Color(0xFFFDAF40).withValues(alpha: 0.5),
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
