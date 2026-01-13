import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import 'product_api.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._api);

  final ProductApi _api;

  @override
  Future<Map<String, dynamic>> getProductDetails(int id) => _api.getProductDetails(id);
}

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(ref.watch(laravelDioProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productApiProvider));
});
