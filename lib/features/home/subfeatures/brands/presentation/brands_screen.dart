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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(
            type: 'shoes_bags',
            slug: parentNode.slug,
            pageTitle: cleanTitle,
            breadcrumb: 'Footwear/Bags • $cleanTitle',
            showBusinessTypeFilter: false,
          ),
        ),
      );
      return;
    }
    
    final childNode = findNode(parentNode.children, cleanItem);
    if (childNode == null) return;
    
    if (childNode.children.isNotEmpty) {
      _showNestedPicker(context, childNode, cleanTitle);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(
            type: 'shoes_bags',
            slug: childNode.slug,
            pageTitle: cleanItem,
            breadcrumb: 'Footwear/Bags • $cleanTitle',
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
                          final hasChildren = child.children.isNotEmpty;
                          
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                
                                // If child has further children, show another picker
                                if (hasChildren) {
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
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      child.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Campton',
                                        color: Color(0xFF1E2021),
                                      ),
                                    ),
                                    if (hasChildren)
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF777F84)),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use categoriesByTypeProvider - backend now returns full nested tree
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
