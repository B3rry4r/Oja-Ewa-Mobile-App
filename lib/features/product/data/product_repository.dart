abstract interface class ProductRepository {
  Future<Map<String, dynamic>> getProductDetails(int id);
}
