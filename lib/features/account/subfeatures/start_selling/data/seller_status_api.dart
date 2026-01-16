import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';
import '../domain/seller_status.dart';

class SellerStatusApi {
  SellerStatusApi(this._dio);

  final Dio _dio;

  /// GET /api/seller/profile - authenticated
  /// Returns null if user has no seller profile (404), or throws on other errors
  Future<SellerStatus?> getMySellerProfile() async {
    debugPrint('[SellerStatusApi] Fetching seller profile...');
    try {
      final res = await _dio.get('/api/seller/profile');
      debugPrint('[SellerStatusApi] Response status: ${res.statusCode}');
      debugPrint('[SellerStatusApi] Response data: ${res.data}');
      
      final data = res.data;
      debugPrint('[SellerStatusApi] data type: ${data.runtimeType}');
      
      if (data is Map<String, dynamic>) {
        // Check if response has 'data' wrapper or is direct
        final inner = data['data'];
        debugPrint('[SellerStatusApi] inner type: ${inner?.runtimeType}, inner: $inner');
        
        if (inner is Map<String, dynamic>) {
          final status = SellerStatus.fromJson(inner);
          debugPrint('[SellerStatusApi] Parsed status: registrationStatus=${status.registrationStatus}, active=${status.active}, isApprovedAndActive=${status.isApprovedAndActive}');
          return status;
        }
        
        // If no 'data' wrapper, try parsing the root directly (API might return seller directly)
        if (data.containsKey('registration_status')) {
          debugPrint('[SellerStatusApi] Parsing root data directly');
          final status = SellerStatus.fromJson(data);
          debugPrint('[SellerStatusApi] Parsed status: registrationStatus=${status.registrationStatus}, active=${status.active}, isApprovedAndActive=${status.isApprovedAndActive}');
          return status;
        }
      }
      debugPrint('[SellerStatusApi] Could not parse response, returning null');
      return null;
    } on DioException catch (e) {
      debugPrint('[SellerStatusApi] DioException: ${e.response?.statusCode} - ${e.message}');
      // 404 means user has no seller profile yet - return null, don't throw
      if (e.response?.statusCode == 404) {
        debugPrint('[SellerStatusApi] 404 - No seller profile, returning null');
        return null;
      }
      throw mapDioError(e);
    } catch (e) {
      debugPrint('[SellerStatusApi] Error: $e');
      throw mapDioError(e);
    }
  }

  /// DELETE /api/seller/profile - authenticated
  /// Deletes the seller's profile/shop
  /// [reason] - Optional reason for deletion
  Future<void> deleteSellerProfile({String? reason}) async {
    debugPrint('[SellerStatusApi] Deleting seller profile...');
    try {
      final res = await _dio.delete(
        '/api/seller/profile',
        data: reason != null ? {'reason': reason} : null,
      );
      debugPrint('[SellerStatusApi] Delete response status: ${res.statusCode}');
      debugPrint('[SellerStatusApi] Delete response: ${res.data}');
    } on DioException catch (e) {
      debugPrint('[SellerStatusApi] Delete DioException: ${e.response?.statusCode} - ${e.message}');
      throw mapDioError(e);
    } catch (e) {
      debugPrint('[SellerStatusApi] Delete Error: $e');
      throw mapDioError(e);
    }
  }
}
