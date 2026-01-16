import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';
import '../domain/seller_status.dart';

class SellerStatusApi {
  SellerStatusApi(this._dio);

  final Dio _dio;

  /// GET /api/seller/profile - authenticated
  /// Returns null if user has no seller profile (404), or throws on other errors
  Future<SellerStatus?> getMySellerProfile() async {
    try {
      final res = await _dio.get('/api/seller/profile');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        // Check if response has 'data' wrapper or is direct
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          return SellerStatus.fromJson(inner);
        }
        // If no 'data' wrapper, try parsing the root directly
        if (data.containsKey('registration_status')) {
          return SellerStatus.fromJson(data);
        }
      }
      return null;
    } on DioException catch (e) {
      // 404 means user has no seller profile yet - return null, don't throw
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw mapDioError(e);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /api/seller/profile - authenticated
  /// Deletes the seller's profile/shop
  /// [reason] - Optional reason for deletion
  Future<void> deleteSellerProfile({String? reason}) async {
    try {
      await _dio.delete(
        '/api/seller/profile',
        data: reason != null ? {'reason': reason} : null,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
