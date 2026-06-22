import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/beauty_kit.dart';
import 'beauty_kits_api.dart';

/// Repository over [BeautyKitsApi]. Mirrors the cart/orders repository pattern:
/// a plain class plus Riverpod providers wired to the shared `laravelDio`.
class BeautyKitsRepository {
  BeautyKitsRepository(this._api);

  final BeautyKitsApi _api;

  Future<List<BeautyKit>> listKits({int perPage = 10, String? category}) =>
      _api.listKits(perPage: perPage, category: category);

  Future<BeautyKit> getKit(String idOrSlug) => _api.getKit(idOrSlug);

  Future<BeautyKitAddToCartResult> addKitToCart(int kitId) =>
      _api.addKitToCart(kitId);
}

final beautyKitsApiProvider = Provider<BeautyKitsApi>((ref) {
  return BeautyKitsApi(ref.watch(laravelDioProvider));
});

final beautyKitsRepositoryProvider = Provider<BeautyKitsRepository>((ref) {
  return BeautyKitsRepository(ref.watch(beautyKitsApiProvider));
});
