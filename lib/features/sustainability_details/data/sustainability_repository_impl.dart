import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import 'sustainability_api.dart';
import 'sustainability_repository.dart';

class SustainabilityRepositoryImpl implements SustainabilityRepository {
  SustainabilityRepositoryImpl(this._api);

  final SustainabilityApi _api;

  @override
  Future<Map<String, dynamic>> getInitiative(int id) => _api.getInitiative(id);
}

final sustainabilityApiProvider = Provider<SustainabilityApi>((ref) {
  return SustainabilityApi(ref.watch(laravelDioProvider));
});

final sustainabilityRepositoryProvider = Provider<SustainabilityRepository>((ref) {
  return SustainabilityRepositoryImpl(ref.watch(sustainabilityApiProvider));
});
