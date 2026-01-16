import 'package:flutter/foundation.dart';

@immutable
class ProductFilters {
  const ProductFilters({
    required this.genders,
    required this.styles,
    required this.tribes,
    required this.priceRange,
    required this.sortOptions,
  });

  final List<String> genders;
  final List<String> styles;
  final List<String> tribes;
  final PriceRange priceRange;
  final List<SortOption> sortOptions;

  factory ProductFilters.fromJson(Map<String, dynamic> json) {
    return ProductFilters(
      genders: (json['genders'] as List?)?.cast<String>() ?? const [],
      styles: (json['styles'] as List?)?.cast<String>() ?? const [],
      tribes: (json['tribes'] as List?)?.cast<String>() ?? const [],
      priceRange: PriceRange.fromJson(json['price_range'] as Map<String, dynamic>? ?? {}),
      sortOptions: (json['sort_options'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(SortOption.fromJson)
              .toList() ??
          const [],
    );
  }

  static const empty = ProductFilters(
    genders: [],
    styles: [],
    tribes: [],
    priceRange: PriceRange.empty,
    sortOptions: [],
  );

  /// Default filter values - no API call needed
  static const defaults = ProductFilters(
    genders: ['Men', 'Women', 'Unisex'],
    styles: ['Traditional', 'Western', 'Casual', 'Formal', 'Fabrics'],
    tribes: ['Yoruba', 'Igbo', 'Hausa', 'Edo', 'Efik', 'Tiv', 'Ijaw', 'Fulani', 'Kanuri', 'Nupe'],
    priceRange: PriceRange(min: 0, max: 500000),
    sortOptions: [
      SortOption(value: 'newest', label: 'Newest'),
      SortOption(value: 'price_low', label: 'Price: Low to High'),
      SortOption(value: 'price_high', label: 'Price: High to Low'),
      SortOption(value: 'popular', label: 'Most Popular'),
      SortOption(value: 'rating', label: 'Top Rated'),
    ],
  );
}

@immutable
class PriceRange {
  const PriceRange({required this.min, required this.max});

  final double min;
  final double max;

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 10000,
    );
  }

  static const empty = PriceRange(min: 0, max: 10000);
}

@immutable
class SortOption {
  const SortOption({required this.value, required this.label});

  final String value;
  final String label;

  factory SortOption.fromJson(Map<String, dynamic> json) {
    return SortOption(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

/// Represents the currently selected filters
@immutable
class SelectedFilters {
  const SelectedFilters({
    this.gender,
    this.style,
    this.tribe,
    this.priceMin,
    this.priceMax,
    this.sortBy,
  });

  final String? gender;
  final String? style;
  final String? tribe;
  final double? priceMin;
  final double? priceMax;
  final String? sortBy;

  bool get hasFilters =>
      gender != null ||
      style != null ||
      tribe != null ||
      priceMin != null ||
      priceMax != null;

  bool get hasSort => sortBy != null;

  SelectedFilters copyWith({
    String? gender,
    String? style,
    String? tribe,
    double? priceMin,
    double? priceMax,
    String? sortBy,
    bool clearGender = false,
    bool clearStyle = false,
    bool clearTribe = false,
    bool clearPrice = false,
    bool clearSort = false,
  }) {
    return SelectedFilters(
      gender: clearGender ? null : (gender ?? this.gender),
      style: clearStyle ? null : (style ?? this.style),
      tribe: clearTribe ? null : (tribe ?? this.tribe),
      priceMin: clearPrice ? null : (priceMin ?? this.priceMin),
      priceMax: clearPrice ? null : (priceMax ?? this.priceMax),
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
    );
  }

  static const empty = SelectedFilters();

  SelectedFilters clear() => empty;
}
