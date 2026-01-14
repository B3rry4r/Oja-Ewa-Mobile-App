// search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';

import '../../../app/router/app_router.dart';
import 'controllers/search_controller.dart';
import '../data/recent_searches_storage.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filters supported by GET /api/products/search
  final List<String> _genderFilters = const ['All', 'Male', 'Female', 'Unisex'];

  int _selectedGenderIndex = 0;
  
  // The submitted query - only this triggers search, not typing
  String _submittedQuery = '';

  @override
  void initState() {
    super.initState();
    // Listen only to update clear button visibility, NOT to trigger search
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Only rebuild to show/hide clear button, NOT to trigger search
    setState(() {});
  }

  void _onSearch() {
    final trimmed = _searchController.text.trim();
    if (trimmed.isEmpty) return;
    
    // Save to recent searches
    ref.read(recentSearchesProvider.notifier).addSearch(trimmed);
    
    // Update submitted query to trigger search
    setState(() {
      _submittedQuery = trimmed;
    });
  }

  void _onRecentSearchTap(String searchTerm) {
    _searchController.text = searchTerm;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    // Trigger search immediately when tapping recent search
    _onSearch();
  }

  void _onGenderTap(int index, String label) {
    setState(() {
      _selectedGenderIndex = index;
    });

    final gender = switch (label.toLowerCase()) {
      'male' => 'male',
      'female' => 'female',
      'unisex' => 'unisex',
      _ => null,
    };

    ref.read(searchFiltersProvider.notifier).setGender(gender);
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final filters = ref.watch(searchFiltersProvider);
    
    // Only search when _submittedQuery is set (user pressed enter/search button)
    final searchAsync = _submittedQuery.isEmpty
        ? const AsyncData(SearchState.empty)
        : ref.watch(searchProvider((query: _submittedQuery, filters: filters)));

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(
                context,
                query: _submittedQuery,
                recentSearches: recentSearches,
                searchAsync: searchAsync,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required String query,
    required List<String> recentSearches,
    required AsyncValue<SearchState> searchAsync,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1),
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
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),

              _buildGenderFilters(),
              const SizedBox(height: 20),

              // If user has typed a query, show results.
              if (query.isNotEmpty) ...[
                _buildResultsSection(searchAsync),
                const SizedBox(height: 28),
              ] else ...[
                _buildRecentSearchesSection(recentSearches),
                const SizedBox(height: 40),
              ],
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
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: Color(0xFF1E2021),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Oja Ewa',
                hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _submittedQuery = '';
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Color(0xFF777F84),
                ),
              ),
            ),
          // Search button
          GestureDetector(
            onTap: _onSearch,
            child: Container(
              height: 49,
              width: 49,
              decoration: const BoxDecoration(
                color: Color(0xFFA15E22),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesSection(List<String> recentSearches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recently Searched',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: Color(0xFF241508),
              ),
            ),
            if (recentSearches.isNotEmpty)
              GestureDetector(
                onTap: () {
                  ref.read(recentSearchesProvider.notifier).clearAll();
                },
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Campton',
                    color: Color(0xFFA15E22),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentSearches.isEmpty)
          const Text(
            'No recent searches',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Campton',
              color: Color(0xFF777F84),
            ),
          )
        else
          _buildChips(recentSearches),
      ],
    );
  }

  Widget _buildChips(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((searchTerm) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _onRecentSearchTap(searchTerm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                searchTerm,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Campton',
                  color: Color(0xFF301C0A),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenderFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: Color(0xFF241508),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(_genderFilters.length, (index) {
            final label = _genderFilters[index];
            return _buildGenderItem(index, label);
          }),
        ),
      ],
    );
  }

  Widget _buildGenderItem(int index, String label) {
    final isSelected = _selectedGenderIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onGenderTap(index, label),
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDEDEDE), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: isSelected
                        ? const Color(0xFFFDAF40)
                        : const Color(0xFF301C0A),
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

  Widget _buildResultsSection(AsyncValue<SearchState> searchAsync) {
    return searchAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Failed to load search results',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No results',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.60,
          ),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            final product = Product(
              id: item.id.toString(),
              title: item.name,
              priceLabel: item.price?.toString() ?? '',
              rating: (item.avgRating ?? 0).toDouble(),
              reviewCount: 0,
              imageUrl: item.image,
              imageColor: 0xFFD9D9D9,
            );

            return ProductCard(
              product: product,
              onTap: () {
                // NOTE: ProductDetailsScreen is currently still static/dummy.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(productId: item.id),
                  ),
                );
              },
              onFavoriteTap: () {},
            );
          },
        );
      },
    );
  }
}
