import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/search_product.dart';
import '../domain/search_result_page.dart';

class SearchApi {
  SearchApi(this._dio);

  final Dio _dio;

  /// Search products using the documented endpoint:
  /// GET /api/products/search
  /// Query params: q (required), gender, style, tribe, price_min, price_max, per_page
  /// Note: Backend docs currently mark this as auth:sanctum; if backend makes it public,
  /// this still works.
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
        // Docs require `q`
        'q': query,
        // Docs define per_page; page is not documented but we send it to support pagination if implemented
        'page': page,
        'per_page': perPage,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (style != null && style.isNotEmpty) 'style': style,
        if (tribe != null && tribe.isNotEmpty) 'tribe': tribe,
        if (priceMin != null) 'price_min': priceMin,
        if (priceMax != null) 'price_max': priceMax,
        
        // These are not in the docs for /search; keep them only if backend supports them.
        // If backend ignores unknown params, it's safe.
        if (categoryType != null && categoryType.isNotEmpty) 'type': categoryType,
        if (categorySlug != null && categorySlug.isNotEmpty) 'category_slug': categorySlug,
        if (sort != null && sort.isNotEmpty) 'sort': sort, // Backend expects 'sort' not 'sort_by'
        if (fabricType != null && fabricType.isNotEmpty) 'fabric_type': fabricType,
      };
      
      final res = await _dio.get(
        '/api/products/search',
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

      // The backend has returned two shapes historically:
      // A) { status, data: { data: [...], meta: {current_page, per_page, total}, links: {...} } }
      // B) { status, data: { current_page, data: [...], per_page, total, ...pagination fields } }
      // So we parse pagination fields from either `payload` or `payload['meta']`.
      final meta = payload['meta'];
      final metaMap = meta is Map<String, dynamic> ? meta : const <String, dynamic>{};

      final itemsRaw = payload['data'];
      final items = (itemsRaw is List)
          ? itemsRaw.whereType<Map<String, dynamic>>().map(SearchProduct.fromJson).toList()
          : const <SearchProduct>[];

      int? _readInt(dynamic v) => (v is num) ? v.toInt() : (v is String ? int.tryParse(v) : null);

      final currentPage = _readInt(payload['current_page']) ?? _readInt(metaMap['current_page']) ?? page;
      final per = _readInt(payload['per_page']) ?? _readInt(metaMap['per_page']) ?? perPage;
      final total = _readInt(payload['total']) ?? _readInt(metaMap['total']) ?? items.length;

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
