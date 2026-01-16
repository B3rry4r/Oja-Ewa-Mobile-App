import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/categories/domain/category_items.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product/presentation/controllers/product_filters_controller.dart';
import 'package:ojaewa/features/product/presentation/controllers/filtered_products_controller.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';
import 'package:ojaewa/features/business_details/presentation/screens/business_details_screen.dart';
import 'package:ojaewa/features/sustainability_details/presentation/screens/sustainability_details_screen.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/filter_sheet.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/sort_sheet.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/business_filter_sheet.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/simple_sort_sheet.dart';
import 'package:ojaewa/features/categories/presentation/controllers/listing_filters_controller.dart';
import 'package:ojaewa/features/categories/presentation/controllers/business_sustainability_search_providers.dart';

/// Product listing screen used for category browsing.
///
/// UI should stay as-is; this wiring replaces hardcoded placeholder data with
/// API-driven category items + pagination.
class ProductListingScreen extends ConsumerStatefulWidget {
  const ProductListingScreen({
    super.key,
    required this.type,
    required this.slug,
    required this.pageTitle,
    required this.breadcrumb,
    required this.showBusinessTypeFilter,
    this.onProductTap,
  });

  final String type;
  final String slug;

  final String pageTitle;
  final String breadcrumb;
  final bool showBusinessTypeFilter;

  /// Allows callers to override what happens when a card is tapped.
  /// If null, defaults to navigating to Product Details.
  /// Callback when a product/business/initiative is tapped.
  /// Receives context and the item ID for navigation.
  final void Function(BuildContext context, int itemId)? onProductTap;

  @override
  ConsumerState<ProductListingScreen> createState() =>
      _ProductListingScreenState();
}

class _ProductListingScreenState extends ConsumerState<ProductListingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    // Trigger prefetch a bit before reaching the bottom.
    if (current >= max - 250) {
      final filters = ref.read(selectedFiltersProvider);
      if (!filters.hasFilters && !filters.hasSort) {
        // Only paginate category items (filtered products don't support pagination yet)
        ref
            .read(
              categoryItemsProvider((
                type: widget.type,
                slug: widget.slug,
              )).notifier,
            )
            .loadMore();
      }
    }
  }

  void _onFiltersChanged() {
    // No manual invalidation needed: filteredProductsProvider watches selectedFiltersProvider
    // and will refresh automatically when filters/sort change.
    setState(() {});
  }

  void _onCategoryItemTap(BuildContext context, CategoryItem tapped) {
    final handler = widget.onProductTap;
    if (handler != null) {
      handler(context, tapped.id);
      return;
    }

    if (tapped is CategoryProductItem) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(productId: tapped.id),
        ),
      );
      return;
    }

    if (tapped is CategoryBusinessItem) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BusinessDetailsScreen(businessId: tapped.id),
        ),
      );
      return;
    }

    if (tapped is CategoryInitiativeItem) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SustainabilityDetailsScreen(initiativeId: tapped.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.type == 'sustainability'
        ? _ListingKind.sustainability
        : (widget.type == 'school' || widget.slug.contains('services'))
            ? _ListingKind.business
            : _ListingKind.product;

    final selectedFilters = ref.watch(selectedFiltersProvider);
    final hasActiveFilters = kind == _ListingKind.product
        ? (selectedFilters.hasFilters || selectedFilters.hasSort)
        : false;

    final businessFilters = ref.watch(businessListingFiltersProvider);
    final hasBusinessFilters = kind == _ListingKind.business &&
        ((businessFilters.state ?? '').isNotEmpty ||
            (businessFilters.city ?? '').isNotEmpty ||
            (businessFilters.sort ?? '').isNotEmpty);

    final sustFilters = ref.watch(sustainabilityListingFiltersProvider);
    final hasSustFilters = kind == _ListingKind.sustainability &&
        (sustFilters.sort ?? '').isNotEmpty;

    final categoryItemsAsync = ref.watch(
      categoryItemsProvider((type: widget.type, slug: widget.slug)),
    );
    final filteredAsync = hasActiveFilters
        ? ref.watch(
            filteredProductsProvider((
              categorySlug: widget.slug,
              categoryName: widget.pageTitle,
            )),
          )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(iconColor: Colors.white),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: categoryItemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load items',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  data: (categoryState) {
                    final childrenAsync = ref.watch(
                      categoryChildrenProvider(categoryState.category.id),
                    );

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                            child: Text(
                              widget.pageTitle,
                              style: const TextStyle(
                                fontSize: 33,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF241508),
                                height: 1.2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.breadcrumb,
                              style: const TextStyle(
                                color: Color(0xFF777F84),
                                fontSize: 14,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Category pills (children of current category).
                          childrenAsync.when(
                            loading: () => const SizedBox(
                              height: 42,
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            error: (e, _) => const SizedBox(height: 42),
                            data: (children) {
                              final pillNames = <String>[
                                'All',
                                ...children.map((c) => c.name),
                              ];
                              return _CategoryPills(
                                pills: pillNames,
                                onTap: (name) {
                                  // Clear filters when changing category
                                  ref
                                      .read(selectedFiltersProvider.notifier)
                                      .clearAll();

                                  if (name == 'All') {
                                    // Refresh current category without filters
                                    ref.invalidate(
                                      categoryItemsProvider((
                                        type: widget.type,
                                        slug: widget.slug,
                                      )),
                                    );
                                    return;
                                  }
                                  final child = children
                                      .where((c) => c.name == name)
                                      .cast()
                                      .firstOrNull;
                                  if (child == null) return;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => ProductListingScreen(
                                        type: widget.type,
                                        slug: child.slug,
                                        pageTitle: child.name,
                                        breadcrumb: widget.breadcrumb,
                                        showBusinessTypeFilter:
                                            widget.showBusinessTypeFilter,
                                        onProductTap: widget.onProductTap,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          _SortFilterRow(
                            showBusinessTypeFilter:
                                widget.showBusinessTypeFilter,
                            onFiltersChanged: _onFiltersChanged,
                            kind: kind,
                          ),

                          const SizedBox(height: 24),

                          // Show filtered products/businesses/sustainability or category items
                          if (hasActiveFilters && filteredAsync != null)
                            _buildFilteredProductsGrid(filteredAsync)
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Builder(
                                builder: (context) {
                                  if (hasBusinessFilters) {
                                    final businessAsync = ref.watch(
                                      filteredBusinessesByCategoryProvider((slug: widget.slug)),
                                    );
                                    return businessAsync.when(
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                      error: (e, _) => Center(child: Text('Failed to load: $e')),
                                      data: (items) => _CategoryItemGrid(
                                        type: widget.type,
                                        items: items,
                                        hasMore: false,
                                        isLoadingMore: false,
                                        onTap: _onCategoryItemTap,
                                      ),
                                    );
                                  }

                                  if (hasSustFilters) {
                                    final sustAsync = ref.watch(
                                      filteredSustainabilityByCategoryProvider((slug: widget.slug)),
                                    );
                                    return sustAsync.when(
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                      error: (e, _) => Center(child: Text('Failed to load: $e')),
                                      data: (items) => _CategoryItemGrid(
                                        type: widget.type,
                                        items: items,
                                        hasMore: false,
                                        isLoadingMore: false,
                                        onTap: _onCategoryItemTap,
                                      ),
                                    );
                                  }

                                  return _CategoryItemGrid(
                                    type: widget.type,
                                    items: categoryState.items,
                                    hasMore: categoryState.hasMore,
                                    isLoadingMore: categoryState.isLoadingMore,
                                    onTap: _onCategoryItemTap,
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredProductsGrid(
    AsyncValue<FilteredProductsState> filteredAsync,
  ) {
    return filteredAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Text('Failed to load filtered products'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _onFiltersChanged,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No products match your filters',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  color: Color(0xFF777F84),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final searchProduct = state.items[index];
                  // Convert SearchProduct to Product for ProductCard
                  final product = Product(
                    id: searchProduct.id.toString(),
                    title: searchProduct.name,
                    priceLabel: 'N${searchProduct.price}',
                    rating: (searchProduct.avgRating ?? 0).toDouble(),
                    reviewCount: 0, // Not available in search result
                    imageUrl: searchProduct.image,
                  );
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(productId: searchProduct.id),
                        ),
                      );
                    },
                    onFavoriteTap: () {
                      // TODO: Handle favorite toggle
                    },
                  );
                },
              ),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _ListingKind { product, business, sustainability }

class _SortFilterRow extends ConsumerWidget {
  const _SortFilterRow({
    required this.showBusinessTypeFilter,
    required this.onFiltersChanged,
    required this.kind,
  });

  final bool showBusinessTypeFilter;
  final VoidCallback onFiltersChanged;
  final _ListingKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kind == _ListingKind.product) {
      final selectedFilters = ref.watch(selectedFiltersProvider);
      final hasActiveFilters = selectedFilters.hasFilters;
      final hasActiveSort = selectedFilters.hasSort;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _ActionButton(
              iconAsset: AppIcons.sort,
              label: hasActiveSort ? 'Sorted' : 'Sort',
              isActive: hasActiveSort,
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => SortOverlay(
                    onApplySort: (_) => onFiltersChanged(),
                    onClearSort: onFiltersChanged,
                  ),
                );
              },
            ),
            const Spacer(),
            _ActionButton(
              iconAsset: AppIcons.filter,
              label: hasActiveFilters ? 'Filtered' : 'Filters',
              isActive: hasActiveFilters,
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FilterSheet(
                    onApplyFilters: (_) => onFiltersChanged(),
                    onClearFilters: onFiltersChanged,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    // Business & Sustainability: separate state providers, no category picker.
    final hasSort = kind == _ListingKind.business
        ? (ref.watch(businessListingFiltersProvider).sort ?? '').isNotEmpty
        : (ref.watch(sustainabilityListingFiltersProvider).sort ?? '').isNotEmpty;

    final hasFilters = kind == _ListingKind.business
        ? ((ref.watch(businessListingFiltersProvider).state ?? '').isNotEmpty ||
            (ref.watch(businessListingFiltersProvider).city ?? '').isNotEmpty)
        : false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ActionButton(
            iconAsset: AppIcons.sort,
            label: hasSort ? 'Sorted' : 'Sort',
            isActive: hasSort,
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SimpleSortSheet(isBusiness: kind == _ListingKind.business),
              );
              onFiltersChanged();
            },
          ),
          const Spacer(),
          if (kind == _ListingKind.business)
            _ActionButton(
              iconAsset: AppIcons.filter,
              label: hasFilters ? 'Filtered' : 'Filters',
              isActive: hasFilters,
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const BusinessFilterSheet(),
                );
                onFiltersChanged();
              },
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA15E22) : Colors.transparent,
          border: Border.all(
            color: isActive ? const Color(0xFFA15E22) : const Color(0xFFCCCCCC),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : const Color(0xFF241508),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPills extends StatefulWidget {
  const _CategoryPills({required this.pills, required this.onTap});

  final List<String> pills;
  final ValueChanged<String> onTap;

  @override
  State<_CategoryPills> createState() => _CategoryPillsState();
}

class _CategoryPillsState extends State<_CategoryPills> {
  String selected = 'All';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: widget.pills.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final pill = widget.pills[index];
          final isSelected = pill == selected;

          return GestureDetector(
            onTap: () {
              setState(() => selected = pill);
              widget.onTap(pill);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA15E22)
                    : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFCCCCCC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  pill,
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
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItemGrid extends StatelessWidget {
  const _CategoryItemGrid({
    required this.type,
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onTap,
  });

  final String type;
  final List<CategoryItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final void Function(BuildContext context, CategoryItem tapped) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'No items found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final count = items.length + ((hasMore && isLoadingMore) ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final item = items[index];
        final product = _toProduct(type, item);

        return ProductCard(
          product: product,
          onTap: () => onTap(context, item),
          onFavoriteTap: () {},
        );
      },
    );
  }

  Product _toProduct(String type, CategoryItem item) {
    // We keep ProductCard UI as-is, mapping other item types onto the card.
    switch (item) {
      case final CategoryProductItem p:
        return Product(
          id: p.id.toString(),
          title: p.name,
          priceLabel: p.price ?? '',
          rating: (p.avgRating ?? 0).toDouble(),
          reviewCount: 0,
          imageUrl: p.image,
          imageColor: 0xFFD9D9D9,
        );
      case final CategoryBusinessItem b:
        return Product(
          id: b.id.toString(),
          title: b.businessName,
          priceLabel: b.category,
          rating: 0,
          reviewCount: 0,
          imageUrl: b.businessLogo,
          imageColor: 0xFFD9D9D9,
        );
      case final CategoryInitiativeItem i:
        return Product(
          id: i.id.toString(),
          title: i.title,
          priceLabel: i.status ?? '',
          rating: 0,
          reviewCount: 0,
          imageUrl: i.imageUrl,
          imageColor: 0xFFD9D9D9,
        );
    }
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
