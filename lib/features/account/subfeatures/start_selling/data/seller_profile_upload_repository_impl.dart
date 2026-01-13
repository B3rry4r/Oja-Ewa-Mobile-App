import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import 'seller_profile_upload_api.dart';
import 'seller_profile_upload_repository.dart';

class SellerProfileUploadRepositoryImpl implements SellerProfileUploadRepository {
  SellerProfileUploadRepositoryImpl(this._api);

  final SellerProfileUploadApi _api;

  @override
  Future<Map<String, dynamic>> upload({required String type, required MultipartFile file}) {
    return _api.upload(type: type, file: file);
  }
}

final sellerProfileUploadApiProvider = Provider<SellerProfileUploadApi>((ref) {
  return SellerProfileUploadApi(ref.watch(laravelDioProvider));
});

final sellerProfileUploadRepositoryProvider = Provider<SellerProfileUploadRepository>((ref) {
  return SellerProfileUploadRepositoryImpl(ref.watch(sellerProfileUploadApiProvider));
});
