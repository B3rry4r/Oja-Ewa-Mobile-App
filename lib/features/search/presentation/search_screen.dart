import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';
import 'package:ojaewa/features/search/presentation/controllers/search_controller.dart';
import 'package:ojaewa/features/search/presentation/controllers/search_suggestions_controller.dart';

/// Helper function to safely parse numeric values from dynamic data
num? _parseNum(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

/// Category types available for search filtering
const _categoryTypes = [
  {'key': 'all', 'label': 'All'},
  {'key': 'textiles', 'label': 'Textiles'},
  {'key': 'afro_beauty_products', 'label': 'Afro Beauty'},
  {'key': 'shoes_bags', 'label': 'Shoes & Bags'},
  {'key': 'art', 'label': 'Art'},
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _selectedCategoryType = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Suggestions are fetched automatically by the provider based on query
    setState(() {}); // Trigger rebuild to update suggestions
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    _focusNode.unfocus();
    ref.read(searchResultsProvider.notifier).search(
      query: query,
      categoryType: _selectedCategoryType == 'all' ? null : _selectedCategoryType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);
    final suggestions = suggestionsAsync.asData?.value ?? [];
    final isSearching = _focusNode.hasFocus && _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with buttons - matching wishlist style
            _buildHeader(context),

            // Main Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppBottomNavBar.height),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // Screen Title
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Campton',
                              color: Color(0xFF241508),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Search Input (consistent UI)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 49,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCCCCCC)),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.search,
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF777F84),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _focusNode,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) => _performSearch(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Campton',
                                    color: Color(0xFF1E2021),
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search Ojá-Ẹwà',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Campton',
                                      color: Color(0xFFCCCCCC),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    ref.read(searchResultsProvider.notifier).clear();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(Icons.close, size: 20, color: Color(0xFF777F84)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Category Type Filter Chips
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categoryTypes.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final type = _categoryTypes[index];
                            final isSelected = _selectedCategoryType == type['key'];
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategoryType = type['key']!);
                                if (_searchController.text.trim().isNotEmpty) {
                                  _performSearch();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFDAF40) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFFCCCCCC),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    type['label']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Campton',
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : const Color(0xFF777F84),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Content
                      Expanded(
                        child: isSearching && suggestions.isNotEmpty
                            ? _buildSuggestions(suggestions)
                            : searchResults.when(
                                data: (results) => results.isEmpty
                                    ? _buildEmptyState()
                                    : _buildSearchResults(results),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Color(0xFFFDAF40)),
                                  ),
                                ),
                                error: (e, _) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Color(0xFF777F84),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Something went wrong',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Campton',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF241508),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Please try again or search with different terms',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Campton',
                                            color: Color(0xFF777F84),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton(
                                          onPressed: _performSearch,
                                          child: const Text(
                                            'Try Again',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Campton',
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFDAF40),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final accessToken = ref.watch(accessTokenProvider);
        final isAuthenticated = accessToken != null && accessToken.isNotEmpty;
        final unreadCount = isAuthenticated
            ? ref.watch(unreadCountProvider).maybeWhen(
                  data: (count) => count,
                  orElse: () => 0,
                )
            : 0;

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
                    // Notification icon with badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        HeaderIconButton(
                          asset: AppIcons.notification,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                          iconColor: Colors.white,
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDAF40),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Campton',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    HeaderIconButton(
                      asset: AppIcons.bag,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestions(List<dynamic> suggestions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final name = suggestion is Map ? (suggestion['name'] ?? '') : suggestion.name ?? '';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SvgPicture.asset(
            AppIcons.search,
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              Color(0xFF777F84),
              BlendMode.srcIn,
            ),
          ),
          title: Text(
            name.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
            ),
          ),
          onTap: () {
            _searchController.text = name.toString();
            _performSearch();
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final hasSearched = ref.read(searchResultsProvider).hasValue;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.search,
            width: 60,
            height: 60,
            colorFilter: const ColorFilter.mode(
              Color(0xFFCCCCCC),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearched ? 'No results found' : 'Search for products & businesses',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: Color(0xFF777F84),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    // Convert search results to Product for ProductCard
    final products = results
        .whereType<Map<String, dynamic>>()
        .map((item) => Product(
              id: (item['id'] as num? ?? 0).toInt().toString(),
              title: item['name'] as String? ?? '',
              priceLabel: formatPrice(_parseNum(item['price'])),
              imageUrl: item['image'] as String?,
              rating: (item['avg_rating'] as num?)?.toDouble() ?? 0,
              reviewCount: (item['review_count'] as num?)?.toInt() ?? 0,
            ))
        .toList();

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 6,
        mainAxisExtent: 248,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(productId: int.tryParse(product.id) ?? 0),
              ),
            );
          },
          onFavoriteTap: () {
            // TODO: Add to wishlist functionality
          },
        );
      },
    );
  }
}

