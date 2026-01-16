import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';
import 'package:ojaewa/features/search/presentation/controllers/search_controller.dart';
import 'package:ojaewa/features/search/presentation/controllers/search_suggestions_controller.dart';

/// Category types available for search filtering
const _categoryTypes = [
  {'key': 'all', 'label': 'All'},
  {'key': 'textiles', 'label': 'Textiles'},
  {'key': 'afro_beauty', 'label': 'Afro Beauty'},
  {'key': 'shoes_bags', 'label': 'Shoes & Bags'},
  {'key': 'art', 'label': 'Art'},
  {'key': 'school', 'label': 'Schools'},
  {'key': 'sustainability', 'label': 'Sustainability'},
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
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              backgroundColor: Color(0xFFFFFBF5),
              iconColor: Color(0xFF241508),
              title: Text(
                'Search',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),

            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
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
                          hintText: 'Search products, businesses...',
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
                          padding: EdgeInsets.all(12),
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
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text(
                          'Search failed: $e',
                          style: const TextStyle(
                            fontFamily: 'Campton',
                            color: Color(0xFF777F84),
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
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        // Handle both product and business results
        if (item is Map<String, dynamic>) {
          final id = item['id'] as int? ?? 0;
          final name = item['name'] as String? ?? item['business_name'] as String? ?? '';
          final image = item['image'] as String? ?? item['logo'] as String?;
          final price = item['price'] as num?;
          final isBusiness = item.containsKey('business_name') || item.containsKey('category');

          return _SearchResultCard(
            id: id,
            name: name,
            imageUrl: image,
            price: price?.toDouble(),
            showPrice: !isBusiness,
            onTap: () {
              if (!isBusiness) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(productId: id),
                  ),
                );
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.showPrice,
    required this.onTap,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final double? price;
  final bool showPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 152,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl!.trim().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const AppImagePlaceholder(
                        width: double.infinity,
                        height: 152,
                        borderRadius: 8,
                      ),
                    ),
                  )
                else
                  const AppImagePlaceholder(
                    width: double.infinity,
                    height: 152,
                    borderRadius: 8,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF241508),
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (showPrice && price != null) ...[
            const SizedBox(height: 4),
            Text(
              '₦${price!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF241508),
                fontFamily: 'Campton',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
