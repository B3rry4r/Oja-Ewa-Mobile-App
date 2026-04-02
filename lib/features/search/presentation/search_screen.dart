import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/ui/price_formatter.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
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
// Product search types (per category system):
// - textiles
// - shoes_bags
// - afro_beauty_products
const _categoryTypes = [
  {'key': 'all', 'label': 'All'},
  {'key': 'textiles', 'label': 'Textiles'},
  {'key': 'afro_beauty_products', 'label': 'Afro Beauty'},
  {'key': 'shoes_bags', 'label': 'Shoes & Bags'},
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
    ref
        .read(searchResultsProvider.notifier)
        .search(
          query: query,
          categoryType: _selectedCategoryType == 'all'
              ? null
              : _selectedCategoryType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final searchResults = ref.watch(searchResultsProvider);
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);
    final suggestions = suggestionsAsync.asData?.value ?? [];
    final isSearching =
        _focusNode.hasFocus && _searchController.text.isNotEmpty;

    return AppPageScaffold(
      title: 'Search',
      showBack: false,
      includeBottomNavSpacing: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppBottomNavBar.height),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 49,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
                color: colors.surface,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.search,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.textTertiary,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: 'Search Ojá-Ẹwà',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          color: colors.textTertiary,
                        ),
                        isCollapsed: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Type Filter Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
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
                        color: isSelected
                            ? const Color(0xFFFDAF40)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? colors.accent : colors.border,
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
                            color: isSelected
                                ? colors.onAccent
                                : colors.textSecondary,
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
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: colors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Something went wrong',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please try again or search with different terms',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Campton',
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _performSearch,
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Campton',
                                    fontWeight: FontWeight.w600,
                                    color: colors.accent,
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
    );
  }

  Widget _buildSuggestions(List<dynamic> suggestions) {
    final colors = context.appColors;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final name = suggestion is Map
            ? (suggestion['name'] ?? '')
            : suggestion.name ?? '';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SvgPicture.asset(
            AppIcons.search,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(colors.textTertiary, BlendMode.srcIn),
          ),
          title: Text(
            name.toString(),
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: colors.textPrimary,
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
    final colors = context.appColors;
    final hasSearched = ref.read(searchResultsProvider).hasValue;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.search,
            width: 60,
            height: 60,
            colorFilter: ColorFilter.mode(colors.borderStrong, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearched
                ? 'No results found'
                : 'Search for products & businesses',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: colors.textSecondary,
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
        .map(
          (item) => Product(
            id: (item['id'] as num? ?? 0).toInt().toString(),
            title: item['name'] as String? ?? '',
            priceLabel: formatPrice(_parseNum(item['price'])),
            imageUrl: item['image'] as String?,
            rating: (item['avg_rating'] as num?)?.toDouble() ?? 0,
            reviewCount: (item['review_count'] as num?)?.toInt() ?? 0,
          ),
        )
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
                builder: (_) => ProductDetailsScreen(
                  productId: int.tryParse(product.id) ?? 0,
                ),
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
