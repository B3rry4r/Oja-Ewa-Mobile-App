import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';
import '../domain/seller_status.dart';

class SellerStatusApi {
  SellerStatusApi(this._dio);

  final Dio _dio;

  /// GET /api/seller/profile - authenticated
  Future<SellerStatus?> getMySellerProfile() async {
    try {
      final res = await _dio.get('/api/seller/profile');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          return SellerStatus.fromJson(inner);
        }
      }
      return null;
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
