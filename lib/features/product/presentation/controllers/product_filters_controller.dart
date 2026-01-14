import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_clients.dart';
import '../../data/product_filters_api.dart';
import '../../domain/product_filters.dart';

// API provider
final productFiltersApiProvider = Provider<ProductFiltersApi>((ref) {
  return ProductFiltersApi(ref.read(laravelDioProvider));
});

/// Fetches available filters from the API (public endpoint)
/// Uses keepAlive to cache the result and prevent repeated calls
final availableFiltersProvider = FutureProvider<ProductFilters>((ref) async {
  ref.keepAlive();
  return ref.read(productFiltersApiProvider).getFilters();
});

/// Manages the currently selected filters - shared across product listing screens
class SelectedFiltersNotifier extends Notifier<SelectedFilters> {
  @override
  SelectedFilters build() => SelectedFilters.empty;

  void setGender(String? gender) {
    state = state.copyWith(gender: gender, clearGender: gender == null);
  }

  void setStyle(String? style) {
    state = state.copyWith(style: style, clearStyle: style == null);
  }

  void setTribe(String? tribe) {
    state = state.copyWith(tribe: tribe, clearTribe: tribe == null);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(
      priceMin: min,
      priceMax: max,
      clearPrice: min == null && max == null,
    );
  }

  void setSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy, clearSort: sortBy == null);
  }

  void applyFilters({
    String? gender,
    String? style,
    String? tribe,
    double? priceMin,
    double? priceMax,
  }) {
    state = SelectedFilters(
      gender: gender,
      style: style,
      tribe: tribe,
      priceMin: priceMin,
      priceMax: priceMax,
      sortBy: state.sortBy, // Preserve sort
    );
  }

  void clearFilters() {
    state = SelectedFilters(sortBy: state.sortBy); // Preserve sort
  }

  void clearAll() {
    state = SelectedFilters.empty;
  }
}

final selectedFiltersProvider = NotifierProvider<SelectedFiltersNotifier, SelectedFilters>(
  SelectedFiltersNotifier.new,
);
