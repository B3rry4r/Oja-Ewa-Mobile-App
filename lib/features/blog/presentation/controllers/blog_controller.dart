import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/blog_repository_impl.dart';
import '../../domain/blog_post.dart';

final blogListProvider = FutureProvider<List<BlogPost>>((ref) async {
  // Use ref.read to avoid rebuild loops
  return ref.read(blogRepositoryProvider).getBlogs();
});

final latestBlogsProvider = FutureProvider<List<BlogPost>>((ref) async {
  // Use ref.read to avoid rebuild loops
  return ref.read(blogRepositoryProvider).getLatestBlogs();
});

final blogBySlugProvider = FutureProvider.family<BlogPost, String>((ref, slug) async {
  // Use ref.read to avoid rebuild loops
  return ref.read(blogRepositoryProvider).getBlogBySlug(slug);
});

final blogSearchProvider = FutureProvider.family<List<BlogPost>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  // Use ref.read to avoid rebuild loops
  return ref.read(blogRepositoryProvider).searchBlogs(query.trim());
});
