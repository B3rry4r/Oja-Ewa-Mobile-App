import 'package:flutter/foundation.dart';

@immutable
class BlogPost {
  const BlogPost({
    required this.id,
    required this.slug,
    required this.title,
    required this.content,
    this.imageUrl,
    this.author,
    this.createdAt,
  });

  final int id;
  final String slug;
  final String title;
  final String content;
  final String? imageUrl;
  final String? author;
  final DateTime? createdAt;

  static BlogPost fromJson(Map<String, dynamic> json) {
    // Attempt to support common Laravel shapes.
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final slug = (json['slug'] as String?) ?? id.toString();
    final title = (json['title'] as String?) ?? '';

    // Content fields vary a lot: content/body/description.
    final content = (json['content'] as String?) ??
        (json['body'] as String?) ??
        (json['description'] as String?) ??
        '';

    final imageUrl = (json['image_url'] as String?) ??
        (json['image'] as String?) ??
        (json['thumbnail'] as String?);

    final author = (json['author'] as String?) ??
        (json['author_name'] as String?) ??
        (json['user'] is Map<String, dynamic> ? (json['user']['name'] as String?) : null);

    final createdAtRaw = json['created_at'];
    DateTime? createdAt;
    if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    return BlogPost(
      id: id,
      slug: slug,
      title: title,
      content: content,
      imageUrl: imageUrl,
      author: author,
      createdAt: createdAt,
    );
  }
}
