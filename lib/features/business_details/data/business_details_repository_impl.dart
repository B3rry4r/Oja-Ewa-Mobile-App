import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import 'business_details_api.dart';
import 'business_details_repository.dart';

class BusinessDetailsRepositoryImpl implements BusinessDetailsRepository {
  BusinessDetailsRepositoryImpl(this._api);

  final BusinessDetailsApi _api;

  @override
  Future<Map<String, dynamic>> getBusiness(int id) => _api.getBusiness(id);
}

final businessDetailsApiProvider = Provider<BusinessDetailsApi>((ref) {
  return BusinessDetailsApi(ref.watch(laravelDioProvider));
});

final businessDetailsRepositoryProvider = Provider<BusinessDetailsRepository>((ref) {
  return BusinessDetailsRepositoryImpl(ref.watch(businessDetailsApiProvider));
});
