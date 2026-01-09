// sort_overlay.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

class SortOverlay extends StatefulWidget {
  /// Current search query text
  final String? searchQuery;
  
  /// Callback when sort is applied
  final Function(String selectedSort)? onApplySort;
  
  /// Callback when sort is cleared
  final VoidCallback? onClearSort;
  
  /// Initial selected sort option
  final String? initialSort;

  const SortOverlay({
    super.key,
    this.searchQuery = '',
    this.onApplySort,
    this.onClearSort,
    this.initialSort,
  });

  @override
  State<SortOverlay> createState() => _SortOverlayState();
}

class _SortOverlayState extends State<SortOverlay> {
  String? _selectedSort;
  
  // Sort options from the IR
  final List<Map<String, dynamic>> _sortOptions = [
    {'id': 'most_recent', 'label': 'Most Recent'},
    {'id': 'new_to_old', 'label': 'New to Old'},
    {'id': 'old_to_new', 'label': 'Old to New'},
    {'id': 'a_to_z', 'label': 'A-Z'},
    {'id': 'z_to_a', 'label': 'Z-A'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort ?? _sortOptions.first['id'];
  }

  void _onApplyPressed() {
    if (widget.onApplySort != null) {
      widget.onApplySort!(_selectedSort!);
    }
    Navigator.of(context).pop(_selectedSort);
  }

  void _onClearPressed() {
    setState(() {
      _selectedSort = null;
    });
    widget.onClearSort?.call();
  }

  @override
  Widget build(BuildContext context) {
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
            
            // Sort overlay content
            _buildSortOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOverlay() {
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
            _buildSortOptions(),
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

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _sortOptions.map((option) {
          final isSelected = _selectedSort == option['id'];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSort = option['id'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected
                          ? const Color(0xFFA15E22)
                          : const Color(0xFF777F84),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option['label'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF241508),
                        ),
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
