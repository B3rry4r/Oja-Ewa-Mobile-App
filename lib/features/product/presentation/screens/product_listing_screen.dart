import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/widgets/product_card.dart';
import 'package:ojaewa/features/categories/domain/category_items.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/product/domain/product.dart';
import 'package:ojaewa/features/product_detail/presentation/product_detail_screen.dart';
import 'package:ojaewa/features/business_details/presentation/screens/business_details_screen.dart';
import 'package:ojaewa/features/sustainability_details/presentation/screens/sustainability_details_screen.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/filter_sheet.dart';
import 'package:ojaewa/features/product_filter_overlay/presentation/widgets/sort_sheet.dart';

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
  final void Function(BuildContext context)? onProductTap;

  @override
  ConsumerState<ProductListingScreen> createState() => _ProductListingScreenState();
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
      ref.read(categoryItemsProvider((type: widget.type, slug: widget.slug)).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(categoryItemsProvider((type: widget.type, slug: widget.slug)));

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
                child: itemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load items',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  data: (state) {
                    final childrenAsync = ref.watch(categoryChildrenProvider(state.category.id));

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
                              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                            ),
                            error: (e, _) => const SizedBox(height: 42),
                            data: (children) {
                              final pillNames = <String>['All', ...children.map((c) => c.name)];
                              return _CategoryPills(
                                pills: pillNames,
                                onTap: (name) {
                                  // Note: We keep UI behavior but we can only load by slug.
                                  // If a child pill is tapped, navigate to the child slug.
                                  if (name == 'All') return;
                                  final child = children.where((c) => c.name == name).cast().firstOrNull;
                                  if (child == null) return;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => ProductListingScreen(
                                        type: widget.type,
                                        slug: child.slug,
                                        pageTitle: child.name,
                                        breadcrumb: widget.breadcrumb,
                                        showBusinessTypeFilter: widget.showBusinessTypeFilter,
                                        onProductTap: widget.onProductTap,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          _SortFilterRow(showBusinessTypeFilter: widget.showBusinessTypeFilter),

                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _CategoryItemGrid(
                              type: widget.type,
                              items: state.items,
                              hasMore: state.hasMore,
                              isLoadingMore: state.isLoadingMore,
                              onTap: (context, tapped) {
                                final handler = widget.onProductTap;
                                if (handler != null) {
                                  handler(context);
                                  return;
                                }

                                if (tapped is CategoryProductItem) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: tapped.id)),
                                  );
                                  return;
                                }

                                if (tapped is CategoryBusinessItem) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => BusinessDetailsScreen(businessId: tapped.id)),
                                  );
                                  return;
                                }

                                if (tapped is CategoryInitiativeItem) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => SustainabilityDetailsScreen(initiativeId: tapped.id)),
                                  );
                                }
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
}

class _SortFilterRow extends StatelessWidget {
  const _SortFilterRow({required this.showBusinessTypeFilter});

  final bool showBusinessTypeFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ActionButton(
            iconAsset: AppIcons.sort,
            label: 'Sort',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SortOverlay(),
              );
            },
          ),
          const Spacer(),
          _ActionButton(
            iconAsset: AppIcons.filter,
            label: 'Filters',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FilterSheet(),
              );
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
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF241508),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPills extends StatefulWidget {
  const _CategoryPills({
    required this.pills,
    required this.onTap,
  });

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
                color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
                border: isSelected ? null : Border.all(color: const Color(0xFFCCCCCC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  pill,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: isSelected ? const Color(0xFFFBFBFB) : const Color(0xFF301C0A),
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
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.60,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)));
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
          imageColor: 0xFFD9D9D9,
        );
      case final CategoryBusinessItem b:
        return Product(
          id: b.id.toString(),
          title: b.businessName,
          priceLabel: b.category,
          rating: 0,
          reviewCount: 0,
          imageColor: 0xFFD9D9D9,
        );
      case final CategoryInitiativeItem i:
        return Product(
          id: i.id.toString(),
          title: i.title,
          priceLabel: i.status ?? '',
          rating: 0,
          reviewCount: 0,
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
