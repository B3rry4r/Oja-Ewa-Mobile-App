import 'package:flutter/foundation.dart';

import 'category_node.dart';

@immutable
class CategoryFormOptions {
  const CategoryFormOptions({
    required this.fabrics,
    required this.styles,
    required this.tribes,
  });

  final List<String> fabrics;
  final List<String> styles;
  final List<String> tribes;

  factory CategoryFormOptions.fromJson(Map<String, dynamic> json) {
    final fabrics = (json['fabrics'] as List?)?.whereType<String>().toList() ?? const [];
    final styles = (json['styles'] as List?)?.whereType<String>().toList() ?? const [];
    final tribes = (json['tribes'] as List?)?.whereType<String>().toList() ?? const [];
    return CategoryFormOptions(fabrics: fabrics, styles: styles, tribes: tribes);
  }
}

@immutable
class CategoryCatalog {
  const CategoryCatalog({
    required this.categories,
    required this.formOptions,
  });

  final Map<String, List<CategoryNode>> categories;
  final CategoryFormOptions formOptions;
}
