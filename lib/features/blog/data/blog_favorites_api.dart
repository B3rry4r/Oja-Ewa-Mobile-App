import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/blog_post.dart';

class BlogFavoritesApi {
  BlogFavoritesApi(this._dio);

  final Dio _dio;

  Future<List<BlogPost>> getFavorites() async {
    try {
      final res = await _dio.get('/api/blogs/favorites');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> addFavorite(int blogId) async {
    try {
      await _dio.post('/api/blogs/favorites', data: {'blog_id': blogId});
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> removeFavorite(int blogId) async {
    try {
      await _dio.delete('/api/blogs/favorites', data: {'blog_id': blogId});
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

List<BlogPost> _extractList(dynamic data) {
  // docs show: { status, data: { data: [blogs], meta } }
  if (data is Map<String, dynamic>) {
    final d = data['data'];
    if (d is Map<String, dynamic>) {
      final list = d['data'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().map(BlogPost.fromJson).toList();
      }
    }

    final list = data['data'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().map(BlogPost.fromJson).toList();
    }
  }

  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(BlogPost.fromJson).toList();
  }

  return const [];
}
