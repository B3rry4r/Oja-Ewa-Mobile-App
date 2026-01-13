import 'blog_post.dart';

abstract interface class BlogRepository {
  Future<List<BlogPost>> getBlogs();
  Future<List<BlogPost>> getLatestBlogs();
  Future<List<BlogPost>> searchBlogs(String query);
  Future<BlogPost> getBlogBySlug(String slug);
}
