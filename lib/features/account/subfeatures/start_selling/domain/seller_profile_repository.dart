import 'seller_profile_payload.dart';

abstract interface class SellerProfileRepository {
  Future<Map<String, dynamic>> createSellerProfile(
    SellerProfilePayload payload,
  );
  Future<Map<String, dynamic>> updateSellerProfile(
    SellerProfilePayload payload,
  );
}
