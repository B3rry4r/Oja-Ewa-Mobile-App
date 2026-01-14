import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../product/presentation/controllers/product_details_controller.dart';
import '../domain/public_seller_profile.dart';

class PublicSellerApi {
  PublicSellerApi(this._dio);

  final Dio _dio;

  Future<PublicSellerProfile> getSeller(int id) async {
    try {
      final res = await _dio.get('/api/sellers/$id');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return PublicSellerProfile.fromJson(inner);
      }
      throw const FormatException('Unexpected seller response');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<ProductDetails>> getSellerProducts({required int sellerId, int page = 1, int perPage = 10}) async {
    try {
      final res = await _dio.get(
        '/api/sellers/$sellerId/products',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      final data = res.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          final list = inner['data'];
          if (list is List) {
            return list.whereType<Map<String, dynamic>>().map(ProductDetails.fromJson).toList();
          }
        }
      }

      return const [];
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
