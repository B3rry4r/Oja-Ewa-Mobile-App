import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/search_repository_impl.dart';
import '../../domain/search_product.dart';
import 'search_controller.dart';

/// Loads suggestions once per app session (per filter state), to avoid hammering the backend
/// on screen rebuilds.
class SearchSuggestionsController extends AsyncNotifier<List<SearchProduct>> {
  Future<List<SearchProduct>> _fetch() {
    // Recompute only when filters change.
    final f = ref.watch(searchFiltersProvider);
    return ref.watch(searchRepositoryProvider).suggestions(
          limit: 10,
          gender: f.gender,
          style: f.style,
          tribe: f.tribe,
          priceMin: f.priceMin,
          priceMax: f.priceMax,
        );
  }

  @override
  FutureOr<List<SearchProduct>> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final searchSuggestionsProvider = AsyncNotifierProvider<SearchSuggestionsController, List<SearchProduct>>(
  SearchSuggestionsController.new,
);
