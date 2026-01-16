import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/search_product.dart';
import '../domain/search_result_page.dart';
import 'search_api.dart';
import 'search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._api);

  final SearchApi _api;

  @override
  Future<SearchResultPage> searchProducts({
    required String query,
    int page = 1,
    int perPage = 10,
    String? gender,
    String? style,
    String? tribe,
    num? priceMin,
    num? priceMax,
    String? categoryType,
    String? categorySlug,
    String? sort,
  }) {
    return _api.searchProducts(
      query: query,
      page: page,
      perPage: perPage,
      gender: gender,
      style: style,
      tribe: tribe,
      priceMin: priceMin,
      priceMax: priceMax,
      categoryType: categoryType,
      categorySlug: categorySlug,
      sort: sort,
    );
  }

  @override
  Future<List<SearchProduct>> suggestions({
    int limit = 10,
    String? gender,
    String? style,
    String? tribe,
    num? priceMin,
    num? priceMax,
  }) {
    return _api.suggestions(
      limit: limit,
      gender: gender,
      style: style,
      tribe: tribe,
      priceMin: priceMin,
      priceMax: priceMax,
    );
  }
}

final searchApiProvider = Provider<SearchApi>((ref) {
  return SearchApi(ref.watch(laravelDioProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.watch(searchApiProvider));
});
