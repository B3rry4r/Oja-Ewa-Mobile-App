import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/blog_repository_impl.dart';
import '../../domain/blog_post.dart';

final blogListProvider = FutureProvider<List<BlogPost>>((ref) async {
  return ref.watch(blogRepositoryProvider).getBlogs();
});

final latestBlogsProvider = FutureProvider<List<BlogPost>>((ref) async {
  return ref.watch(blogRepositoryProvider).getLatestBlogs();
});

final blogBySlugProvider = FutureProvider.family<BlogPost, String>((ref, slug) async {
  return ref.watch(blogRepositoryProvider).getBlogBySlug(slug);
});

final blogSearchProvider = FutureProvider.family<List<BlogPost>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  return ref.watch(blogRepositoryProvider).searchBlogs(query.trim());
});
