// category_screen.dart
import 'package:flutter/material.dart';
import 'package:ojaewa/features/home/presentation/widgets/filter_sheet.dart';

typedef CategoryItemTap = void Function(CategorySection section, String item);

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryDescription;

  /// Sections to show (each section has items/subcategories)
  final List<CategorySection> sections;

  /// Called when a subcategory item is tapped.
  final CategoryItemTap? onItemTap;

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
  Map<String, bool> _expandedSections = {};

  void _onBackPressed() {
    Navigator.pop(context);
  }

  void _onFilterPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) => FilterSheet(
        showBusinessType: widget.showBusinessTypeFilter,
        initialFilters: {
          'location': 'Ghana',
          'businessType': 'Freelancer',
          'reviewRange': '5-4',
        },
        onApplyFilters: (filters) {
          print('Applied filters: $filters');
        },
        onClearFilters: () {
          print('Filters cleared');
        },
      ),
    );
  }

  void _onSettingsPressed() {
    print('Settings button pressed');
  }

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
        child: Column(
          children: [
            // Header with buttons
            if (widget.showHeaderButtons) _buildHeader(),
            
            // Main Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      child: Row(
        children: [
          // Back Button (left)
          _buildHeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: _onBackPressed,
          ),

          const Spacer(),

          // Right-side actions grouped together
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.tune_rounded,
                onPressed: _onFilterPressed,
              ),
              const SizedBox(width: 16),
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                onPressed: _onSettingsPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          
          // Sections
          ...widget.sections.map((section) {
            return _buildCategorySection(section);
          }).expand((widget) => [widget, const SizedBox(height: 0)]),
          
          const SizedBox(height: 40),
        ],
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
