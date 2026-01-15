import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';
import '../domain/business_status.dart';

class BusinessStatusApi {
  BusinessStatusApi(this._dio);

  final Dio _dio;

  /// GET /api/business - authenticated
  Future<List<BusinessStatus>> getMyBusinesses() async {
    try {
      final res = await _dio.get('/api/business');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().map(BusinessStatus.fromJson).toList();
        }
      }
      return const [];
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
