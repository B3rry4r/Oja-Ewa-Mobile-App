import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/search_repository_impl.dart';
import '../../domain/search_product.dart';

typedef SearchFilters = ({
  String? gender,
  String? style,
  String? tribe,
  num? priceMin,
  num? priceMax,
});

class SearchFiltersController extends Notifier<SearchFilters> {
  @override
  SearchFilters build() {
    return (
      gender: null,
      style: null,
      tribe: null,
      priceMin: null,
      priceMax: null,
    );
  }

  void setGender(String? gender) {
    state = (
      gender: gender,
      style: state.style,
      tribe: state.tribe,
      priceMin: state.priceMin,
      priceMax: state.priceMax,
    );
  }

  void clearAll() {
    state = (
      gender: null,
      style: null,
      tribe: null,
      priceMin: null,
      priceMax: null,
    );
  }
}

final searchFiltersProvider =
    NotifierProvider<SearchFiltersController, SearchFilters>(
      SearchFiltersController.new,
    );

final searchSuggestionsProvider = FutureProvider<List<SearchProduct>>((
  ref,
) async {
  final f = ref.watch(searchFiltersProvider);
  return ref
      .watch(searchRepositoryProvider)
      .suggestions(
        limit: 10,
        gender: f.gender,
        style: f.style,
        tribe: f.tribe,
        priceMin: f.priceMin,
        priceMax: f.priceMax,
      );
});

@immutable
class SearchState {
  const SearchState({
    required this.query,
    required this.page,
    required this.perPage,
    required this.total,
    required this.items,
    this.isLoadingMore = false,
  });

  final String query;
  final int page;
  final int perPage;
  final int total;
  final List<SearchProduct> items;
  final bool isLoadingMore;

  bool get hasMore => items.length < total;

  SearchState copyWith({
    String? query,
    int? page,
    int? perPage,
    int? total,
    List<SearchProduct>? items,
    bool? isLoadingMore,
  }) {
    return SearchState(
      query: query ?? this.query,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  static const empty = SearchState(
    query: '',
    page: 1,
    perPage: 10,
    total: 0,
    items: [],
  );
}

typedef SearchArgs = ({String query, SearchFilters filters});

final searchProvider =
    AsyncNotifierProvider.family<SearchController, SearchState, SearchArgs>(
      SearchController.new,
    );

class SearchController extends AsyncNotifier<SearchState> {
  SearchController(this._args);

  final SearchArgs _args;

  @override
  Future<SearchState> build() async {
    final q = _args.query.trim();
    if (q.isEmpty) return SearchState.empty;

    final f = _args.filters;
    final page = await ref
        .watch(searchRepositoryProvider)
        .searchProducts(
          query: q,
          page: 1,
          perPage: 10,
          gender: f.gender,
          style: f.style,
          tribe: f.tribe,
          priceMin: f.priceMin,
          priceMax: f.priceMax,
        );
    return SearchState(
      query: q,
      page: page.currentPage,
      perPage: page.perPage,
      total: page.total,
      items: page.items,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    if (current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;
    final f = _args.filters;
    final res = await ref
        .read(searchRepositoryProvider)
        .searchProducts(
          query: current.query,
          page: nextPage,
          perPage: current.perPage,
          gender: f.gender,
          style: f.style,
          tribe: f.tribe,
          priceMin: f.priceMin,
          priceMax: f.priceMax,
        );

    state = AsyncData(
      current.copyWith(
        page: res.currentPage,
        perPage: res.perPage,
        total: res.total,
        items: [...current.items, ...res.items],
        isLoadingMore: false,
      ),
    );
  }
}
