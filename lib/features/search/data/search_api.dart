import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/search_product.dart';
import '../domain/search_result_page.dart';

class SearchApi {
  SearchApi(this._dio);

  final Dio _dio;

  Future<SearchResultPage> searchProducts({
    required String query,
    int page = 1,
    int perPage = 10,
    String? gender,
    String? style,
    String? tribe,
    String? fabricType,
    num? priceMin,
    num? priceMax,
    String? categoryType,
    String? categorySlug,
    String? sort,
  }) async {
    try {
      final queryParams = {
        if (query.isNotEmpty) 'search': query,
        'page': page,
        'per_page': perPage,
        if (categoryType != null && categoryType.isNotEmpty) 'type': categoryType,
        if (categorySlug != null && categorySlug.isNotEmpty) 'category_slug': categorySlug,
        if (sort != null && sort.isNotEmpty) 'sort_by': sort,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (style != null && style.isNotEmpty) 'style': style,
        if (tribe != null && tribe.isNotEmpty) 'tribe': tribe,
        if (fabricType != null && fabricType.isNotEmpty) 'fabric_type': fabricType,
        if (priceMin != null) 'price_min': priceMin,
        if (priceMax != null) 'price_max': priceMax,
      };
      
      final res = await _dio.get(
        '/api/products/browse',
        queryParameters: queryParams,
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }

      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }

      final itemsRaw = payload['data'];
      final items = (itemsRaw is List)
          ? itemsRaw.whereType<Map<String, dynamic>>().map(SearchProduct.fromJson).toList()
          : const <SearchProduct>[];

      final currentPage = (payload['current_page'] as num?)?.toInt() ?? page;
      final per = (payload['per_page'] as num?)?.toInt() ?? perPage;
      final total = (payload['total'] as num?)?.toInt() ?? items.length;

      return SearchResultPage(items: items, currentPage: currentPage, perPage: per, total: total);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<SearchProduct>> suggestions({
    int limit = 10,
    String? gender,
    String? style,
    String? tribe,
    num? priceMin,
    num? priceMax,
  }) async {
    try {
      final res = await _dio.get(
        '/api/products/suggestions',
        queryParameters: {
          'limit': limit,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (style != null && style.isNotEmpty) 'style': style,
          if (tribe != null && tribe.isNotEmpty) 'tribe': tribe,
          if (priceMin != null) 'price_min': priceMin,
          if (priceMax != null) 'price_max': priceMax,
        },
      );

      final data = res.data;
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map(SearchProduct.fromJson).toList();
      }

      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().map(SearchProduct.fromJson).toList();
        }
      }

      return const [];
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
