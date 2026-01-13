import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';
import '../domain/faq_item.dart';

class FaqApi {
  FaqApi(this._dio);

  final Dio _dio;

  Future<List<FaqItem>> getFaqs() async {
    try {
      final res = await _dio.get('/api/faqs');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<FaqItem>> searchFaqs(String query) async {
    try {
      final res = await _dio.get('/api/faqs/search', queryParameters: {'query': query});
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

List<FaqItem> _extractList(dynamic data) {
  if (data is Map<String, dynamic>) {
    final list = data['data'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().map(FaqItem.fromJson).toList();
    }
  }
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(FaqItem.fromJson).toList();
  }
  return const [];
}
