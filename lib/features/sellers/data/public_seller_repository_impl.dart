import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../../product/presentation/controllers/product_details_controller.dart';
import '../domain/public_seller_profile.dart';
import 'public_seller_api.dart';

class PublicSellerRepository {
  PublicSellerRepository(this._api);

  final PublicSellerApi _api;

  Future<PublicSellerProfile> getSeller(int id) => _api.getSeller(id);

  Future<List<ProductDetails>> getSellerProducts({required int sellerId, int page = 1, int perPage = 10}) =>
      _api.getSellerProducts(sellerId: sellerId, page: page, perPage: perPage);
}

final publicSellerApiProvider = Provider<PublicSellerApi>((ref) {
  return PublicSellerApi(ref.watch(laravelDioProvider));
});

final publicSellerRepositoryProvider = Provider<PublicSellerRepository>((ref) {
  return PublicSellerRepository(ref.watch(publicSellerApiProvider));
});
