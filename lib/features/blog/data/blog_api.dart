import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/blog_post.dart';

class BlogApi {
  BlogApi(this._dio);

  final Dio _dio;

  Future<List<BlogPost>> getBlogs() async {
    try {
      final res = await _dio.get('/api/blogs');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<BlogPost> getBlogBySlug(String slug) async {
    try {
      final res = await _dio.get('/api/blogs/$slug');
      return _extractOne(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<BlogPost>> getLatestBlogs() async {
    try {
      final res = await _dio.get('/api/blogs/latest');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<BlogPost>> searchBlogs(String query) async {
    try {
      final res = await _dio.get('/api/blogs/search', queryParameters: {'query': query});
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

List<BlogPost> _extractList(dynamic data) {
  // Supports shapes:
  // - { data: { data: [ ... ] } }  (paginated Laravel response)
  // - { data: [ ... ] }
  // - [ ... ]
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    // Check for nested pagination: { data: { data: [...] } }
    if (inner is Map<String, dynamic>) {
      final list = inner['data'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().map(BlogPost.fromJson).toList();
      }
    }
    // Simple wrapper: { data: [...] }
    if (inner is List) {
      return inner.whereType<Map<String, dynamic>>().map(BlogPost.fromJson).toList();
    }
  }

  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(BlogPost.fromJson).toList();
  }

  return const [];
}

BlogPost _extractOne(dynamic data) {
  if (data is Map<String, dynamic>) {
    final item = data['data'];
    if (item is Map<String, dynamic>) return BlogPost.fromJson(item);
    return BlogPost.fromJson(data);
  }

  throw const FormatException('Unexpected blog response');
}
