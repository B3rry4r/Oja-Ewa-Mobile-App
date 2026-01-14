import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/advert.dart';

class AdvertsApi {
  AdvertsApi(this._dio);

  final Dio _dio;

  Future<List<Advert>> listAdverts({String? position, int page = 1, int perPage = 10}) async {
    try {
      final res = await _dio.get(
        '/api/adverts',
        queryParameters: {
          if (position != null && position.isNotEmpty) 'position': position,
          'page': page,
          'per_page': perPage,
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      final payload = data['data'];
      if (payload is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      final list = payload['data'];
      if (list is! List) return const [];
      return list.whereType<Map<String, dynamic>>().map(Advert.fromJson).toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Advert> getAdvert(int id) async {
    try {
      final res = await _dio.get('/api/adverts/$id');
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      final payload = data['data'];
      if (payload is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return Advert.fromJson(payload);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
