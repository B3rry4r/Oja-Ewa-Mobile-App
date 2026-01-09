// filter_sheet.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

class FilterSheet extends StatefulWidget {
  /// Callback when filters are applied
  final Function(Map<String, dynamic> filters)? onApplyFilters;

  /// Callback when filters are cleared
  final VoidCallback? onClearFilters;

  /// Whether to show the business type section
  final bool showBusinessType;

  /// Initial filter values
  final Map<String, dynamic>? initialFilters;

  const FilterSheet({
    super.key,
    this.onApplyFilters,
    this.onClearFilters,
    this.showBusinessType = true,
    this.initialFilters,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // Filter state
  String? _selectedLocation;
  String? _selectedBusinessType;
  String? _selectedReviewRange;

  // Business type options
  final List<String> _businessTypes = ['Freelancer', 'Company'];

  // Location options
  final List<String> _locations = [
    'Ghana',
    'Nigeria',
    'South Africa',
    'Kenya',
    'Uganda',
  ];

  // Review range options
  final List<Map<String, dynamic>> _reviewRanges = [
    {'range': '5-4', 'color': const Color(0xFFFFDB80)},
    {'range': '4-3', 'color': const Color(0xFFFFDB80)},
    {'range': '3-1', 'color': const Color(0xFFFFDB80)},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with provided values
    if (widget.initialFilters != null) {
      _selectedLocation = widget.initialFilters!['location'];
      _selectedBusinessType = widget.initialFilters!['businessType'];
      _selectedReviewRange = widget.initialFilters!['reviewRange'];
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildFilterSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1), // Background color from IR
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

            // Location filter section
            _buildSectionTitle('Location'),
            const SizedBox(height: 8),
            _buildLocationFilters(),
            const SizedBox(height: 24),

            // Business Type filter section (conditional)
            if (widget.showBusinessType) ...[
              _buildSectionTitle('Business Type'),
              const SizedBox(height: 8),
              _buildBusinessTypeFilters(),
              const SizedBox(height: 24),
            ],

            // Reviews filter section
            _buildSectionTitle('Reviews'),
            const SizedBox(height: 8),
            _buildReviewFilters(),
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

  Widget _buildLocationFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _locations.map((location) {
          final isSelected = _selectedLocation == location;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLocation = isSelected ? null : location;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFA15E22)
                      : const Color(0xFFCCCCCC),
                ),
              ),
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFFFBFBFB)
                      : const Color(0xFF301C0A),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusinessTypeFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        children: _businessTypes.map((type) {
          final isSelected = _selectedBusinessType == type;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBusinessType = isSelected ? null : type;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFA15E22)
                      : const Color(0xFFCCCCCC),
                ),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFFFBFBFB)
                      : const Color(0xFF301C0A),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        children: _reviewRanges.map((reviewData) {
          final isSelected = _selectedReviewRange == reviewData['range'];
          final color = reviewData['color'] as Color;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedReviewRange = isSelected ? null : reviewData['range'];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFA15E22)
                      : const Color(0xFFCCCCCC),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Text
                  Text(
                    reviewData['range'],
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFFBFBFB)
                          : const Color(0xFF301C0A),
                    ),
                  ),
                ],
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
              onPressed: () {
                setState(() {
                  _selectedLocation = null;
                  _selectedBusinessType = null;
                  _selectedReviewRange = null;
                });
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
                final filters = {
                  'location': _selectedLocation,
                  'businessType': _selectedBusinessType,
                  'reviewRange': _selectedReviewRange,
                };

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
