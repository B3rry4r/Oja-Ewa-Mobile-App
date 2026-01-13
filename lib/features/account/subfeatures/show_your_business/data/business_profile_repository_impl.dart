import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import '../domain/business_profile_payload.dart';
import '../domain/business_profile_repository.dart';
import 'business_profile_api.dart';

class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  BusinessProfileRepositoryImpl(this._api);

  final BusinessProfileApi _api;

  @override
  Future<Map<String, dynamic>> createBusiness(BusinessProfilePayload payload) {
    return _api.createBusiness(payload);
  }
}

final businessProfileApiProvider = Provider<BusinessProfileApi>((ref) {
  return BusinessProfileApi(ref.watch(laravelDioProvider));
});

final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((ref) {
  return BusinessProfileRepositoryImpl(ref.watch(businessProfileApiProvider));
});
