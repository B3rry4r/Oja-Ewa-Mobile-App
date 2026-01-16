import '../domain/category_items.dart';
import '../domain/category_node.dart';
import '../domain/category_catalog.dart';

abstract interface class CategoryRepository {
  Future<CategoryCatalog> getAllCategories();

  Future<List<CategoryNode>> getCategories({required String type});
  Future<List<CategoryNode>> getChildren(int id);

  Future<({CategoryNode category, List<CategoryItem> items, int currentPage, int lastPage, int total})> getItems({
    required String type,
    required String slug,
    int page,
    int perPage,
  });
}
