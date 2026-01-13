import '../domain/search_product.dart';
import '../domain/search_result_page.dart';

abstract interface class SearchRepository {
  Future<SearchResultPage> searchProducts({
    required String query,
    int page,
    int perPage,
    String? gender,
    String? style,
    String? tribe,
    num? priceMin,
    num? priceMax,
  });

  Future<List<SearchProduct>> suggestions({
    int limit,
    String? gender,
    String? style,
    String? tribe,
    num? priceMin,
    num? priceMax,
  });
}
