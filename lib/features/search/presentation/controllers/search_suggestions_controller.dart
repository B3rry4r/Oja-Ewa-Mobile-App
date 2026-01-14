import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../data/search_repository_impl.dart';
import '../../domain/search_product.dart';
import 'search_controller.dart';

/// Loads suggestions and memoizes results per filter key.
/// This prevents accidental rebuild loops from spamming the backend.
class SearchSuggestionsController extends AsyncNotifier<List<SearchProduct>> {
  String? _lastKey;

  String _keyForFilters(SearchFilters f) {
    return '${f.gender}|${f.style}|${f.tribe}|${f.priceMin}|${f.priceMax}';
  }

  Future<List<SearchProduct>> _fetch(SearchFilters f) {
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
  FutureOr<List<SearchProduct>> build() async {
    ref.keepAlive();

    final token = ref.watch(accessTokenProvider);
    if (token == null || token.isEmpty) return const <SearchProduct>[];

    final f = ref.watch(searchFiltersProvider);
    final key = _keyForFilters(f);

    final current = state.asData?.value;
    if (current != null && _lastKey == key) {
      // No filter change -> return cached suggestions, no network call.
      return current;
    }

    _lastKey = key;
    return _fetch(f);
  }
}

final searchSuggestionsProvider = AsyncNotifierProvider<SearchSuggestionsController, List<SearchProduct>>(
  SearchSuggestionsController.new,
);
