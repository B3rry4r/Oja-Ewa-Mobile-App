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
      // On update, include existing file URLs in the JSON body so the API's
      // 'sometimes|required' validation passes for signature and documents.
      // These are URLs (already uploaded), not new file paths to upload.
      final body = payload.toJson(includeFileFields: false);
      if ((payload.authorizedSignatorySignature ?? '').isNotEmpty) {
        body['authorized_signatory_signature'] = payload.authorizedSignatorySignature;
      }
      if ((payload.identityDocument ?? '').isNotEmpty) {
        body['identity_document'] = payload.identityDocument;
      }
      if ((payload.businessCertificate ?? '').isNotEmpty) {
        body['business_certificate'] = payload.businessCertificate;
      }
      if ((payload.businessLogo ?? '').isNotEmpty) {
        body['business_logo'] = payload.businessLogo;
      }
      final res = await _dio.put(
        '/api/seller/profile',
        data: body,
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
