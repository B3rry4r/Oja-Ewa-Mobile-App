import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';
import '../domain/seller_profile_payload.dart';

class SellerProfileApi {
  SellerProfileApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createSellerProfile(SellerProfilePayload payload) async {
    try {
      final res = await _dio.post('/api/seller/profile', data: payload.toJson());
      if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
      throw const FormatException('Unexpected seller profile response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
