import 'package:flutter/foundation.dart';

import 'search_product.dart';

@immutable
class SearchResultPage {
  const SearchResultPage({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
  });

  final List<SearchProduct> items;
  final int currentPage;
  final int perPage;
  final int total;

  bool get hasMore => items.length < total;

  SearchResultPage copyWith({
    List<SearchProduct>? items,
    int? currentPage,
    int? perPage,
    int? total,
  }) {
    return SearchResultPage(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
    );
  }
}
