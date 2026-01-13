import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';
import '../domain/business_profile_payload.dart';

class BusinessProfileApi {
  BusinessProfileApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createBusiness(BusinessProfilePayload payload) async {
    try {
      final res = await _dio.post('/api/business', data: payload.toJson());
      if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
      throw const FormatException('Unexpected business create response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Upload endpoint for business profile files.
  /// docs: POST /api/business/{id}/upload (multipart)
  Future<Map<String, dynamic>> uploadFile({
    required int businessId,
    required String fileType, // business_logo|business_certificates|identity_document
    required MultipartFile file,
  }) async {
    try {
      final form = FormData.fromMap({
        'file': file,
        'file_type': fileType,
      });

      final res = await _dio.post(
        '/api/business/$businessId/upload',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
      throw const FormatException('Unexpected upload response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
