import 'package:dio/dio.dart';

import 'package:ojaewa/core/network/dio_error_mapper.dart';
import '../domain/wishlist_item.dart';

class WishlistApi {
  WishlistApi(this._dio);

  final Dio _dio;

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final res = await _dio.get('/api/wishlist');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> add({required WishlistableType type, required int id}) async {
    try {
      await _dio.post(
        '/api/wishlist',
        data: {
          'wishlistable_type': type == WishlistableType.product ? 'product' : 'business_profile',
          'wishlistable_id': id,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> remove({required WishlistableType type, required int id}) async {
    try {
      await _dio.delete(
        '/api/wishlist',
        data: {
          'wishlistable_type': type == WishlistableType.product ? 'product' : 'business_profile',
          'wishlistable_id': id,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

List<WishlistItem> _extractList(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) {
      final list = inner['data'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().map(WishlistItem.fromJson).toList();
      }
    }

    final list = data['data'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().map(WishlistItem.fromJson).toList();
    }
  }

  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(WishlistItem.fromJson).toList();
  }

  return const [];
}
