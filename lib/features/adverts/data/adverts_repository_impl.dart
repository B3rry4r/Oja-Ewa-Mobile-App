import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/advert.dart';
import 'adverts_api.dart';
import 'adverts_repository.dart';

class AdvertsRepositoryImpl implements AdvertsRepository {
  AdvertsRepositoryImpl(this._api);

  final AdvertsApi _api;

  @override
  Future<List<Advert>> listAdverts({String? position, int page = 1, int perPage = 10}) {
    return _api.listAdverts(position: position, page: page, perPage: perPage);
  }

  @override
  Future<Advert> getAdvert(int id) => _api.getAdvert(id);
}

final advertsApiProvider = Provider<AdvertsApi>((ref) {
  return AdvertsApi(ref.watch(laravelDioProvider));
});

final advertsRepositoryProvider = Provider<AdvertsRepository>((ref) {
  return AdvertsRepositoryImpl(ref.watch(advertsApiProvider));
});
