import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/logistics_models.dart';

class LogisticsApi {
  LogisticsApi(this._dio);

  final Dio _dio;

  Future<List<SellerShippingQuotes>> getShippingQuotes(
    LogisticsQuoteRequest request,
  ) async {
    try {
      final res = await _dio.post(
        '/api/logistics/quotes',
        data: request.toJson(),
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      final payload = data['data'];
      if (payload is! List) return const [];
      return payload
          .whereType<Map>()
          .map(
            (item) =>
                SellerShippingQuotes.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
