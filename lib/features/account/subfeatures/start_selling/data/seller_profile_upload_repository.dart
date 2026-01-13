import 'package:dio/dio.dart';

abstract interface class SellerProfileUploadRepository {
  Future<Map<String, dynamic>> upload({required String type, required MultipartFile file});
}
