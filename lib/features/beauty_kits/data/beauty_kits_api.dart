import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/beauty_kit.dart';

/// Result of adding a whole kit to the cart.
class BeautyKitAddToCartResult {
  const BeautyKitAddToCartResult({
    required this.addedCount,
    required this.skippedCount,
    required this.itemsCount,
    required this.cartTotal,
  });

  final int addedCount;
  final int skippedCount;
  final int itemsCount;
  final num cartTotal;

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static BeautyKitAddToCartResult fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final skipped = data['skipped'];
    return BeautyKitAddToCartResult(
      addedCount: _parseNum(data['added_count'])?.toInt() ?? 0,
      skippedCount: skipped is List ? skipped.length : 0,
      itemsCount: _parseNum(data['items_count'])?.toInt() ?? 0,
      cartTotal: _parseNum(data['cart_total']) ?? 0,
    );
  }
}

/// Network access for the public Beauty Kits API.
///
/// Mirrors [CartApi]/[OrdersApi]: a thin Dio wrapper that maps errors via
/// [mapDioError] and parses the standard {status,message,data} envelope.
class BeautyKitsApi {
  BeautyKitsApi(this._dio);

  final Dio _dio;

  /// GET /api/beauty-kits — paginated active kits.
  Future<List<BeautyKit>> listKits({int perPage = 10, String? category}) async {
    try {
      final res = await _dio.get(
        '/api/beauty-kits',
        queryParameters: {
          'per_page': perPage,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      // `data` is a Laravel paginator: { data: [...], current_page, ... }.
      final paginator = data['data'];
      final list = paginator is Map<String, dynamic>
          ? paginator['data']
          : paginator;
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BeautyKit.fromJson)
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /api/beauty-kits/{idOrSlug} — detail with bundled products.
  Future<BeautyKit> getKit(String idOrSlug) async {
    try {
      final res = await _dio.get('/api/beauty-kits/$idOrSlug');
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      final inner = (data['data'] as Map?)?.cast<String, dynamic>();
      final kitJson = (inner?['beauty_kit'] as Map?)?.cast<String, dynamic>();
      if (kitJson == null) {
        throw const FormatException('Beauty kit not found in response');
      }
      return BeautyKit.fromJson(kitJson);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /api/beauty-kits/{id}/add-to-cart — adds all kit items to the cart.
  Future<BeautyKitAddToCartResult> addKitToCart(int kitId) async {
    try {
      final res = await _dio.post('/api/beauty-kits/$kitId/add-to-cart');
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      return BeautyKitAddToCartResult.fromJson(data);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
