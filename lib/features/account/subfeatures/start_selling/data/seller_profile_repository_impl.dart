import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import '../domain/seller_profile_payload.dart';
import '../domain/seller_profile_repository.dart';
import 'seller_profile_api.dart';

class SellerProfileRepositoryImpl implements SellerProfileRepository {
  SellerProfileRepositoryImpl(this._api);

  final SellerProfileApi _api;

  @override
  Future<Map<String, dynamic>> createSellerProfile(SellerProfilePayload payload) {
    return _api.createSellerProfile(payload);
  }
}

final sellerProfileApiProvider = Provider<SellerProfileApi>((ref) {
  return SellerProfileApi(ref.watch(laravelDioProvider));
});

final sellerProfileRepositoryProvider = Provider<SellerProfileRepository>((ref) {
  return SellerProfileRepositoryImpl(ref.watch(sellerProfileApiProvider));
});
