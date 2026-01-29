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
          // All children will be tappable - we'll determine behavior in the handler
          items.add(child.name);
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
    final cleanItem = item.trim();
    
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
    
    if (item == 'View All') {
      // Navigate to parent category
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(
            type: 'textiles',
            slug: parentNode.slug,
            pageTitle: cleanTitle,
            breadcrumb: 'Textiles • $cleanTitle',
            showBusinessTypeFilter: false,
          ),
        ),
      );
      return;
    }
    
    // Find the tapped child node
    final childNode = findNode(parentNode.children, cleanItem);
    if (childNode == null) {
      debugPrint('❌ Child node not found for: $cleanItem');
      return;
    }
    
    debugPrint('✅ Found child node: ${childNode.name}, has ${childNode.children.length} children');
    
    // Check if this child has its own children (nested category)
    if (childNode.children.isNotEmpty) {
      debugPrint('📋 Showing nested picker for ${childNode.name} with ${childNode.children.length} items');
      // Show modal picker for nested selection
      _showNestedPicker(context, childNode, cleanTitle);
    } else {
      debugPrint('🎯 Navigating to leaf node: ${childNode.name}');
      // Leaf node - navigate to product listing
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(
            type: 'textiles',
            slug: childNode.slug,
            pageTitle: cleanItem,
            breadcrumb: 'Textiles • $cleanTitle',
            showBusinessTypeFilter: false,
          ),
        ),
      );
    }
  }

  void _showNestedPicker(BuildContext context, CategoryNode node, String parentTitle) {
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
                    // Drag handle
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
                    // Title
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: node.children.length,
                        itemBuilder: (context, index) {
                          final child = node.children[index];
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
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFFDEDEDE), width: 1),
                                  ),
                                ),
                                child: Text(
                                  child.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Campton',
                                    color: Color(0xFF1E2021),
                                  ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use categoriesByTypeProvider - backend now returns full nested tree
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
