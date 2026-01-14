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
  List<SearchProduct>? _cachedResult;

  String _keyForFilters(SearchFilters f) {
    return '${f.gender}|${f.style}|${f.tribe}|${f.priceMin}|${f.priceMax}';
  }

  Future<List<SearchProduct>> _fetch(SearchFilters f) {
    // Use ref.read to avoid triggering rebuilds
    return ref.read(searchRepositoryProvider).suggestions(
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
    // Use ref.read for token check to avoid rebuild loops
    final token = ref.read(accessTokenProvider);
    if (token == null || token.isEmpty) return const <SearchProduct>[];

    // Use ref.read for filters to avoid rebuild loops
    final f = ref.read(searchFiltersProvider);
    final key = _keyForFilters(f);

    // Return cached result if filters haven't changed
    if (_cachedResult != null && _lastKey == key) {
      return _cachedResult!;
    }

    _lastKey = key;
    _cachedResult = await _fetch(f);
    return _cachedResult!;
  }

  /// Call this method to refresh suggestions when filters change
  void refreshIfNeeded() {
    final f = ref.read(searchFiltersProvider);
    final key = _keyForFilters(f);
    if (_lastKey != key) {
      ref.invalidateSelf();
    }
  }
}

final searchSuggestionsProvider = AsyncNotifierProvider<SearchSuggestionsController, List<SearchProduct>>(
  SearchSuggestionsController.new,
);
