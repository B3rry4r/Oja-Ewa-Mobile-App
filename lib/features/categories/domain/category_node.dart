import 'package:flutter/foundation.dart';

@immutable
class CategoryNode {
  const CategoryNode({
    required this.id,
    required this.type,
    required this.name,
    required this.slug,
    this.description,
    this.parentId,
    this.children = const [],
  });

  final int id;
  final String type; // market|beauty|brand|school|music|sustainability
  final String name;
  final String slug;
  final String? description;
  final int? parentId;
  final List<CategoryNode> children;

  static CategoryNode fromJson(Map<String, dynamic> json) {
    final childrenRaw = json['children'];
    final children = (childrenRaw is List)
        ? childrenRaw.whereType<Map<String, dynamic>>().map(CategoryNode.fromJson).toList()
        : const <CategoryNode>[];

    return CategoryNode(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      description: json['description'] as String?,
      parentId: (json['parent_id'] as num?)?.toInt(),
      children: children,
    );
  }
}
