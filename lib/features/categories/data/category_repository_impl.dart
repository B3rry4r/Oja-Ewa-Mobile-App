import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/category_items.dart';
import '../domain/category_node.dart';
import 'category_api.dart';
import 'category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._api);

  final CategoryApi _api;

  @override
  Future<Map<String, List<CategoryNode>>> getAllCategories() => _api.getAllCategories();

  @override
  Future<List<CategoryNode>> getCategories({required String type}) => _api.getCategories(type: type);

  @override
  Future<List<CategoryNode>> getChildren(int id) => _api.getChildren(id);

  @override
  Future<({CategoryNode category, List<CategoryItem> items, int currentPage, int lastPage, int total})> getItems({
    required String type,
    required String slug,
    int page = 1,
    int perPage = 15,
  }) => _api.getItems(type: type, slug: slug, page: page, perPage: perPage);
}

final categoryApiProvider = Provider<CategoryApi>((ref) {
  return CategoryApi(ref.watch(laravelDioProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryApiProvider));
});
