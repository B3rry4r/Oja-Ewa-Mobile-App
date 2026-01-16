// sort_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/features/product/domain/product_filters.dart';
import 'package:ojaewa/features/product/presentation/controllers/product_filters_controller.dart';

class SortOverlay extends ConsumerStatefulWidget {
  /// Callback when sort is applied
  final Function(String selectedSort)? onApplySort;
  
  /// Callback when sort is cleared
  final VoidCallback? onClearSort;

  const SortOverlay({
    super.key,
    this.onApplySort,
    this.onClearSort,
  });

  @override
  ConsumerState<SortOverlay> createState() => _SortOverlayState();
}

class _SortOverlayState extends ConsumerState<SortOverlay> {
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    // Initialize with current sort selection
    _selectedSort = ref.read(selectedFiltersProvider).sortBy;
  }

  void _onApplyPressed() {
    // Apply sort to the provider
    ref.read(selectedFiltersProvider.notifier).setSortBy(_selectedSort);
    
    if (widget.onApplySort != null && _selectedSort != null) {
      widget.onApplySort!(_selectedSort!);
    }
    Navigator.of(context).pop(_selectedSort);
  }

  void _onClearPressed() {
    setState(() {
      _selectedSort = null;
    });
    ref.read(selectedFiltersProvider.notifier).setSortBy(null);
    widget.onClearSort?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Use hardcoded default sort options - no API call needed
    final sortOptions = ProductFilters.defaults.sortOptions;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer to push content to bottom
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            
            // Sort overlay content - use defaults directly, no async needed
            _buildSortOverlay(sortOptions),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOverlay(List<SortOption> sortOptions) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            _buildHeader(),
            
            // Sort options list
            const SizedBox(height: 16),
            _buildSortOptions(sortOptions),
            const SizedBox(height: 40),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
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
            'Sort By',
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

  Widget _buildSortOptions(List<SortOption> sortOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: sortOptions.map((option) {
          final isSelected = _selectedSort == option.value;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSort = option.value;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFDF3E7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Radio button
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFA15E22) : const Color(0xFFCCCCCC),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFA15E22),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Label
                    Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: const Color(0xFF1E2021),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
              onPressed: _onClearPressed,
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
              onPressed: _onApplyPressed,
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
