import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';
import '../domain/bank_option.dart';
import '../domain/seller_profile_payload.dart';

class SellerProfileApi {
  SellerProfileApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createSellerProfile(
    SellerProfilePayload payload,
  ) async {
    try {
      final res = await _dio.post(
        '/api/seller/profile',
        data: payload.toJson(),
      );
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      throw const FormatException('Unexpected seller profile response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateSellerProfile(
    SellerProfilePayload payload,
  ) async {
    try {
      final res = await _dio.put(
        '/api/seller/profile',
        data: payload.toJson(includeFileFields: false),
      );
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      throw const FormatException('Unexpected seller profile response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<BankOption>> getBanks({String country = 'NG'}) async {
    try {
      final res = await _dio.get(
        '/api/payment/banks',
        queryParameters: {'country': country},
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected banks response');
      }
      final list = data['data'];
      if (list is! List) {
        return const [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(BankOption.fromJson)
          .where((bank) => bank.code.isNotEmpty && bank.name.isNotEmpty)
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
