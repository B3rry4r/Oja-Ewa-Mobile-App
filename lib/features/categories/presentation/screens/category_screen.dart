// category_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

typedef CategoryItemTap = void Function(CategorySection section, String item);

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryDescription;

  /// Sections to show (each section has items/subcategories)
  final List<CategorySection> sections;

  /// Called when a subcategory item is tapped.
  final CategoryItemTap? onItemTap;

  /// Optional retry callback used for API-backed categories.
  /// If provided, the empty state can offer a refresh action.
  final VoidCallback? onRetry;

  /// Whether to show the business type filter in the filter sheet.
  /// (Beauty category needs this.)
  final bool showBusinessTypeFilter;

  final bool showHeaderButtons;

  const CategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.sections,
    this.onItemTap,
    this.onRetry,
    this.showBusinessTypeFilter = false,
    this.showHeaderButtons = true,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class CategorySection {
  final String title;

  /// Whether this section header shows a bottom divider.
  final bool hasBorder;

  /// Whether to show the trailing expand/collapse icon.
  final bool hasTrailingIcon;

  /// Items shown when expanded.
  final List<String> items;

  /// Whether the section is expandable/collapsible.
  ///
  /// For the category UI, sections are meant to behave like custom dropdowns,
  /// so this defaults to true.
  final bool isExpandable;

  final VoidCallback? onTap;

  CategorySection({
    required this.title,
    this.hasBorder = true,
    this.hasTrailingIcon = true,
    required this.items,
    this.isExpandable = true,
    this.onTap,
  });
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Map<String, bool> _expandedSections = {};

  Widget _buildEmptyState() {
    final retry = widget.onRetry;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Keep it simple; no redesign, but consistent with other empty states.
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.category_outlined, size: 64, color: Color(0xFF777F84)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nothing here yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Campton',
              color: Color(0xFF241508),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'No categories were found for this section.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: Color(0xFF777F84),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (retry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA15E22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // void _onBackPressed() {
  //   Navigator.pop(context);
  // }

  void _toggleSectionExpansion(String sectionTitle) {
    setState(() {
      _expandedSections[sectionTitle] = !(_expandedSections[sectionTitle] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with buttons
            if (widget.showHeaderButtons) _buildHeader(context),
            
            // Main Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const AppHeader(
      iconColor: Colors.white,
    );
  }

  Widget _buildContent() {
    final hasSections = widget.sections.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Category Title
            Text(
              widget.categoryTitle,
              style: const TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
                fontFamily: 'Campton',
                color: Color(0xFF241508),
              ),
            ),

            const SizedBox(height: 4),

            // Category Description
            Text(
              widget.categoryDescription,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            ),

            const SizedBox(height: 28),

            if (!hasSections) _buildEmptyState(),

            if (hasSections) ...[
              // Sections
              ...widget.sections.map((section) {
                return _buildCategorySection(section);
              }).expand((w) => [w, const SizedBox(height: 0)]),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(CategorySection section) {
    final isExpanded = _expandedSections[section.title] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (custom dropdown trigger)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: section.isExpandable
                ? () => _toggleSectionExpansion(section.title)
                : section.onTap,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: section.hasBorder
                  ? const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFDEDEDE)),
                      ),
                    )
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton',
                      color: Color(0xFF1E2021),
                    ),
                  ),
                  if (section.hasTrailingIcon)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: const Color(0xFF1E2021),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Items List (only when expanded)
        if (section.isExpandable && isExpanded && section.items.isNotEmpty)
          _buildSectionItems(section),
      ],
    );
  }

  Widget _buildSectionItems(CategorySection section) {
    final items = section.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        // final isLast = index == items.length - 1;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final cb = widget.onItemTap;
              if (cb != null) {
                cb(section, item);
              } else {
                debugPrint('Selected item: ${section.title} $item');
              }
            },
            child: Container(
              width: double.infinity,
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                // border: Border(
                //   bottom: BorderSide(
                //     color: isLast ? Colors.transparent : const Color(0xFFDEDEDE),
                //   ),
                // ),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Campton',
                  color: Color(0xFF1E2021),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

}
