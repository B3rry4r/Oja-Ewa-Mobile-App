import '../domain/business_profile_payload.dart';

abstract interface class BusinessProfileRepository {
  Future<Map<String, dynamic>> createBusiness(BusinessProfilePayload payload);
}
