import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

/// Footwear/Bags screen - displays products (not businesses).
/// Category type: shoes_bags → Returns Products
class BrandsScreen extends ConsumerWidget {
  const BrandsScreen({super.key});

  List<CategorySection> _buildNestedSections(List<CategoryNode> nodes) {
    final sections = <CategorySection>[];
    
    for (final node in nodes) {
      final hasChildren = node.children.isNotEmpty;
      if (!hasChildren) continue;
      
      final hasDeepNesting = node.children.any((ch) => ch.children.isNotEmpty);
      
      if (!hasDeepNesting) {
        sections.add(CategorySection(
          title: node.name,
          items: ['View All', ...node.children.map((ch) => ch.name)],
          isExpandable: true,
          hasBorder: true,
        ));
      } else {
        final items = <String>['View All'];
        for (final child in node.children) {
          if (child.children.isNotEmpty) {
            items.add('▶ ${child.name}');
          } else {
            items.add(child.name);
          }
        }
        
        sections.add(CategorySection(
          title: node.name,
          items: items,
          isExpandable: true,
          hasBorder: true,
        ));
      }
    }
    
    return sections;
  }

  void _handleItemTap(BuildContext context, List<CategoryNode> rootCats, CategorySection section, String item) {
    final cleanTitle = section.title.trim();
    final cleanItem = item.replaceAll('▶ ', '').trim();
    
    CategoryNode? findNode(List<CategoryNode> nodes, String name) {
      for (final node in nodes) {
        if (node.name == name) return node;
        final found = findNode(node.children, name);
        if (found != null) return found;
      }
      return null;
    }
    
    final parentNode = findNode(rootCats, cleanTitle);
    if (parentNode == null) return;
    
    if (item.startsWith('▶')) {
      final nestedNode = findNode(parentNode.children, cleanItem);
      if (nestedNode == null) return;
      
      if (nestedNode.children.isNotEmpty) {
        _showNestedPicker(context, nestedNode, cleanTitle);
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              type: 'shoes_bags',
              slug: nestedNode.slug,
              pageTitle: cleanItem,
              breadcrumb: 'Footwear/Bags • $cleanTitle • $cleanItem',
              showBusinessTypeFilter: false,
            ),
          ),
        );
      }
      return;
    }
    
    CategoryNode? targetNode;
    if (item == 'View All') {
      targetNode = parentNode;
    } else {
      targetNode = findNode(parentNode.children, cleanItem);
    }
    
    if (targetNode == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListingScreen(
          type: 'shoes_bags',
          slug: targetNode!.slug,
          pageTitle: item == 'View All' ? cleanTitle : cleanItem,
          breadcrumb: 'Footwear/Bags • $cleanTitle',
          showBusinessTypeFilter: false,
        ),
      ),
    );
  }

  void _showNestedPicker(BuildContext context, CategoryNode node, String parentTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF8F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: Color(0xFF241508),
                  ),
                ),
                const SizedBox(height: 16),
                ...node.children.map((child) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        
                        // If child has further children (Shoes/Bags), show another picker
                        if (child.children.isNotEmpty) {
                          _showNestedPicker(context, child, '$parentTitle • ${node.name}');
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductListingScreen(
                                type: 'shoes_bags',
                                slug: child.slug,
                                pageTitle: child.name,
                                breadcrumb: 'Footwear/Bags • $parentTitle • ${node.name}',
                                showBusinessTypeFilter: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              child.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Campton',
                                color: Color(0xFF1E2021),
                              ),
                            ),
                            if (child.children.isNotEmpty)
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF777F84)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider('shoes_bags'));

    return categoriesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF603814),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF603814),
        body: SafeArea(
          child: Center(
            child: Text(
              'Failed to load categories',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      data: (cats) {
        // Build nested sections - Shoes/Bags has: Women/Men (2-level) and Kids (4-level: Kids → Male/Female → Shoes/Bags → items)
        final sections = _buildNestedSections(cats);

        return CategoryScreen(
          categoryTitle: 'Footwear/Bags',
          categoryDescription: 'Discover premium African footwear and bags.',
          sections: sections,
          onItemTap: (section, item) {
            _handleItemTap(context, cats, section, item);
          },
        );
      },
    );
  }
}
