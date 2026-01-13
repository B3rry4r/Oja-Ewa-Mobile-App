import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/blog_post.dart';
import '../domain/blog_repository.dart';
import 'blog_api.dart';

class BlogRepositoryImpl implements BlogRepository {
  BlogRepositoryImpl(this._api);

  final BlogApi _api;

  @override
  Future<List<BlogPost>> getBlogs() => _api.getBlogs();

  @override
  Future<BlogPost> getBlogBySlug(String slug) => _api.getBlogBySlug(slug);

  @override
  Future<List<BlogPost>> getLatestBlogs() => _api.getLatestBlogs();

  @override
  Future<List<BlogPost>> searchBlogs(String query) => _api.searchBlogs(query);
}

final blogApiProvider = Provider<BlogApi>((ref) {
  return BlogApi(ref.watch(laravelDioProvider));
});

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepositoryImpl(ref.watch(blogApiProvider));
});
