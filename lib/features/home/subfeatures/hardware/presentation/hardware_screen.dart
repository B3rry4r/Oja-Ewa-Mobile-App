import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

class HardwareScreen extends ConsumerWidget {
  const HardwareScreen({super.key});

  List<CategorySection> _buildNestedSections(List<CategoryNode> nodes) {
    final sections = <CategorySection>[];

    for (final node in nodes) {
      if (node.children.isEmpty) continue;

      final hasDeepNesting = node.children.any(
        (child) => child.children.isNotEmpty,
      );
      final items = <String>[
        'View All',
        ...node.children.map((child) => child.name),
      ];

      sections.add(
        CategorySection(
          title: node.name,
          items: items,
          isExpandable: true,
          hasBorder: true,
        ),
      );

      if (!hasDeepNesting) {
        continue;
      }
    }

    return sections;
  }

  void _handleItemTap(
    BuildContext context,
    List<CategoryNode> rootCategories,
    CategorySection section,
    String item,
  ) {
    final parentNode = _findNode(rootCategories, section.title.trim());
    if (parentNode == null) return;

    if (item == 'View All') {
      _pushListing(
        context,
        slug: parentNode.slug,
        pageTitle: parentNode.name,
        breadcrumb: 'Hardware • ${parentNode.name}',
      );
      return;
    }

    final childNode = _findNode(parentNode.children, item.trim());
    if (childNode == null) return;

    if (childNode.children.isNotEmpty) {
      _showNestedPicker(
        context,
        node: childNode,
        breadcrumb: 'Hardware • ${parentNode.name} • ${childNode.name}',
      );
      return;
    }

    _pushListing(
      context,
      slug: childNode.slug,
      pageTitle: childNode.name,
      breadcrumb: 'Hardware • ${parentNode.name}',
    );
  }

  void _showNestedPicker(
    BuildContext context, {
    required CategoryNode node,
    required String breadcrumb,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8F1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Text(
                        node.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Campton',
                          color: Color(0xFF241508),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFDEDEDE)),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: node.children.length,
                        itemBuilder: (context, index) {
                          final child = node.children[index];
                          final hasChildren = child.children.isNotEmpty;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();

                                if (hasChildren) {
                                  _showNestedPicker(
                                    context,
                                    node: child,
                                    breadcrumb: '$breadcrumb • ${child.name}',
                                  );
                                  return;
                                }

                                _pushListing(
                                  context,
                                  slug: child.slug,
                                  pageTitle: child.name,
                                  breadcrumb: breadcrumb,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFDEDEDE),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        child.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Campton',
                                          color: Color(0xFF1E2021),
                                        ),
                                      ),
                                    ),
                                    if (hasChildren)
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Color(0xFF777F84),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _pushListing(
    BuildContext context, {
    required String slug,
    required String pageTitle,
    required String breadcrumb,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListingScreen(
          type: 'hardware',
          slug: slug,
          pageTitle: pageTitle,
          breadcrumb: breadcrumb,
          showBusinessTypeFilter: false,
        ),
      ),
    );
  }

  CategoryNode? _findNode(List<CategoryNode> nodes, String name) {
    for (final node in nodes) {
      if (node.name == name) return node;
      final nested = _findNode(node.children, name);
      if (nested != null) return nested;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider('hardware'));

    return categoriesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF603814),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: const Color(0xFF603814),
        body: SafeArea(
          child: Center(
            child: Text(
              'Failed to load hardware categories',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      data: (categories) => CategoryScreen(
        categoryTitle: 'Hardware',
        categoryDescription: 'Shop platform-managed hardware products',
        showBusinessTypeFilter: false,
        sections: _buildNestedSections(categories),
        onItemTap: (section, item) =>
            _handleItemTap(context, categories, section, item),
      ),
    );
  }
}
