import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/features/search/data/search_repository_impl.dart';
import 'package:ojaewa/features/search/domain/search_product.dart';
import 'product_filters_controller.dart';

@immutable
class FilteredProductsState {
  const FilteredProductsState({
    required this.items,
    required this.currentPage,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<SearchProduct> items;
  final int currentPage;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  FilteredProductsState copyWith({
    List<SearchProduct>? items,
    int? currentPage,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FilteredProductsState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  static const empty = FilteredProductsState(
    items: [],
    currentPage: 1,
    total: 0,
    hasMore: false,
  );
}

/// Args for filtered products: category slug acts as search query context
typedef FilteredProductsArgs = ({String categorySlug, String categoryName});

/// Provider for filtered/sorted products using the search API
final filteredProductsProvider = FutureProvider.family<FilteredProductsState, FilteredProductsArgs>((ref, arg) async {
  // Check auth
  final token = ref.read(accessTokenProvider);
  if (token == null || token.isEmpty) {
    return FilteredProductsState.empty;
  }

  // Watch filters so we rebuild when they change
  final filters = ref.watch(selectedFiltersProvider);

  // Use category name as search query
  final query = arg.categoryName;

  final result = await ref.read(searchRepositoryProvider).searchProducts(
        query: query,
        page: 1,
        perPage: 15,
        gender: filters.gender,
        style: filters.style,
        tribe: filters.tribe,
        priceMin: filters.priceMin,
        priceMax: filters.priceMax,
        categorySlug: arg.categorySlug,
        sort: filters.sortBy,
      );

  return FilteredProductsState(
    items: result.items,
    currentPage: result.currentPage,
    total: result.total,
    hasMore: result.items.length < result.total,
  );
});
