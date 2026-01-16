import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/category_items.dart';
import '../domain/category_node.dart';

class CategoryApi {
  CategoryApi(this._dio);

  final Dio _dio;

  Future<Map<String, List<CategoryNode>>> getAllCategories() async {
    try {
      final res = await _dio.get('/api/categories/all');
      final data = res.data;
      if (data is! Map<String, dynamic>) return const {};
      final payload = data['data'];
      if (payload is! Map<String, dynamic>) return const {};

      final out = <String, List<CategoryNode>>{};
      for (final entry in payload.entries) {
        final v = entry.value;
        if (v is List) {
          out[entry.key] = v.whereType<Map<String, dynamic>>().map(CategoryNode.fromJson).toList();
        }
      }
      return out;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<CategoryNode>> getCategories({required String type}) async {
    try {
      final res = await _dio.get('/api/categories', queryParameters: {'type': type});
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().map(CategoryNode.fromJson).toList();
        }
      }
      return const [];
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<CategoryNode>> getChildren(int id) async {
    try {
      final res = await _dio.get('/api/categories/$id/children');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final d = data['data'];
        if (d is Map<String, dynamic>) {
          final children = d['children'];
          if (children is List) {
            return children.whereType<Map<String, dynamic>>().map(CategoryNode.fromJson).toList();
          }
        }
      }
      return const [];
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<({CategoryNode category, List<CategoryItem> items, int currentPage, int lastPage, int total})> getItems({
    required String type,
    required String slug,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final res = await _dio.get(
        '/api/categories/$type/$slug/items',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');

      final d = data['data'];
      if (d is! Map<String, dynamic>) throw const FormatException('Unexpected response');

      final cat = d['category'];
      final itemsBlock = d['items'];

      if (cat is! Map<String, dynamic> || itemsBlock is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }

      final category = CategoryNode.fromJson(cat);

      final itemsRaw = itemsBlock['data'];
      final items = (itemsRaw is List)
          ? itemsRaw.whereType<Map<String, dynamic>>().map((j) => parseCategoryItem(type, j)).toList()
          : const <CategoryItem>[];

      final currentPage = (itemsBlock['current_page'] as num?)?.toInt() ?? page;
      final lastPage = (itemsBlock['last_page'] as num?)?.toInt() ?? currentPage;
      final total = (itemsBlock['total'] as num?)?.toInt() ?? items.length;

      return (category: category, items: items, currentPage: currentPage, lastPage: lastPage, total: total);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
