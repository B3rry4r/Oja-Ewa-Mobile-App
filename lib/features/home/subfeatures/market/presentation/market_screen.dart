import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/screens/category_screen.dart';
import 'package:ojaewa/features/product/presentation/screens/product_listing_screen.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  /// Build sections with proper nested dropdown support
  /// For categories with deep nesting (Kids → Female/Male → items), 
  /// we flatten into a list where nested items appear as sub-items in the items list
  List<CategorySection> _buildNestedSections(List<CategoryNode> nodes) {
    final sections = <CategorySection>[];
    
    for (final node in nodes) {
      final hasChildren = node.children.isNotEmpty;
      
      if (!hasChildren) {
        // Leaf with no children - shouldn't happen at top level but handle it
        continue;
      }
      
      // Check if this node has deep nesting (children have children)
      final hasDeepNesting = node.children.any((ch) => ch.children.isNotEmpty);
      
      if (!hasDeepNesting) {
        // Simple 2-level: node → children (leaves)
        sections.add(CategorySection(
          title: node.name,
          items: ['View All', ...node.children.map((ch) => ch.name)],
          isExpandable: true,
          hasBorder: true,
        ));
      } else {
        // Deep nesting: node → children (branches) → grandchildren (leaves)
        // Example: Kids → Female/Male → actual items
        // Show as: Kids (expandable) with items: [View All, ▶ Female, ▶ Male]
        // When user taps ▶ Female, we navigate or show a sub-picker
        
        final items = <String>['View All'];
        for (final child in node.children) {
          if (child.children.isNotEmpty) {
            // Child has its own children - mark it as expandable with ▶
            items.add('▶ ${child.name}');
          } else {
            // Child is a leaf
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
    
    // Find the node by traversing the tree
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
    
    // Check if item starts with ▶ (indicates nested category)
    if (item.startsWith('▶')) {
      // User tapped a nested category (e.g., ▶ Female under Kids)
      // Show a sub-picker or navigate to that nested category's listing
      final nestedNode = findNode(parentNode.children, cleanItem);
      if (nestedNode == null) return;
      
      // For now, show bottom sheet with the nested category's children
      if (nestedNode.children.isNotEmpty) {
        _showNestedPicker(context, nestedNode, cleanTitle);
      } else {
        // Navigate to products for this nested node
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              type: 'textiles',
              slug: nestedNode.slug,
              pageTitle: cleanItem,
              breadcrumb: 'Textiles • $cleanTitle • $cleanItem',
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
      // Find child by name
      targetNode = findNode(parentNode.children, cleanItem);
    }
    
    if (targetNode == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListingScreen(
          type: 'textiles',
          slug: targetNode!.slug,
          pageTitle: item == 'View All' ? cleanTitle : cleanItem,
          breadcrumb: 'Textiles • $cleanTitle',
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductListingScreen(
                              type: 'textiles',
                              slug: child.slug,
                              pageTitle: child.name,
                              breadcrumb: 'Textiles • $parentTitle • ${node.name}',
                              showBusinessTypeFilter: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
                        ),
                        child: Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Campton',
                            color: Color(0xFF1E2021),
                          ),
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
    final categoriesAsync = ref.watch(categoriesByTypeProvider('textiles'));

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
        // Build nested sections recursively
        // Textiles has: Women/Men/Unisex (2-level) and Kids (3-level: Kids → Female/Male → items)
        final sections = _buildNestedSections(cats.where((c) => c.name.toLowerCase() != 'fabrics').toList());

        return CategoryScreen(
          categoryTitle: 'Textiles',
          categoryDescription: 'Shop premium african textiles.',
          sections: sections,
          onItemTap: (section, item) {
            _handleItemTap(context, cats, section, item);
          },
        );
      },
    );
  }
}
