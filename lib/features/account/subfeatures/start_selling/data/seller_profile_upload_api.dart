import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';

class SellerProfileUploadApi {
  SellerProfileUploadApi(this._dio);

  final Dio _dio;

  /// docs: POST /api/seller/profile/upload
  /// form-data: file, type (identity_document|business_certificate|business_logo)
  Future<Map<String, dynamic>> upload({required String type, required MultipartFile file}) async {
    try {
      final form = FormData.fromMap({'file': file, 'type': type});
      final res = await _dio.post(
        '/api/seller/profile/upload',
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
