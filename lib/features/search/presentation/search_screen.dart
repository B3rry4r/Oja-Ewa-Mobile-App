// search_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import '../../../app/router/app_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ['Makeup', 'Men', 'Beauty'];
  final List<String> _categories = ['Market', 'Beauty', 'Music', 'Brands'];

  int _selectedCategoryIndex = -1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    print('Searching for: $query');
    // Implement search functionality
  }

  void _onRecentSearchTap(String searchTerm) {
    setState(() {
      _searchController.text = searchTerm;
    });
    _onSearch(searchTerm);
  }

  void _onCategoryTap(int index, String category) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    print('Selected category: $category');
    // Navigate to category page or filter results
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814), // #603814
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with buttons
            _buildHeader(),

            // Main Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 104,
      color: const Color(0xFF603814),
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                HeaderIconButton(
                  asset: AppIcons.notification,
                  iconColor: Colors.white,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                const SizedBox(width: 8),
                HeaderIconButton(
                  asset: AppIcons.bag,
                  iconColor: Colors.white,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1), // #fff8f1
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppBottomNavBar.height),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Title
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: const Color(0xFF241508), // #241508
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              _buildSearchBar(),

              const SizedBox(height: 20),

              // Recently Searched Section
              _buildRecentlySearched(),

              const SizedBox(height: 20),

              // Categories Section
              _buildCategories(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 49,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCCCCCC), // #cccccc
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search_rounded, size: 24, color: const Color(0xFF777F84)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: const Color(0xFF1E2021),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'search Oja Ewa',
                hintStyle: TextStyle(color: const Color(0xFFCCCCCC)),
              ),
              onChanged: _onSearch,
              onSubmitted: _onSearch,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
                _onSearch('');
              },
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: const Color(0xFF777F84),
              ),
            ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildRecentlySearched() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Searched',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF241508), // #241508
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((searchTerm) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _onRecentSearchTap(searchTerm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFCCCCCC),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    searchTerm,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Campton',
                      color: const Color(0xFF301C0A), // #301c0a
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: const Color(0xFF241508), // #241508
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(_categories.length, (index) {
            final category = _categories[index];
            return _buildCategoryItem(index, category);
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index, String category) {
    final isSelected = _selectedCategoryIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCategoryTap(index, category),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: const Color(0xFFDEDEDE), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: isSelected
                        ? const Color(0xFFFDAF40) // Brand color when selected
                        : const Color(0xFF301C0A), // #301c0a
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isSelected
                      ? const Color(0xFFFDAF40)
                      : const Color(0xFF777F84),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
