import 'package:flutter/material.dart';

import 'package:ojaewa/features/categories/domain/category_node.dart';

/// Bottom-sheet drill-down picker for CategoryNode trees.
///
/// Returns the selected node (usually a leaf). Users drill down by tapping nodes
/// with children; leaf nodes are selectable.
Future<CategoryNode?> showCategoryTreePickerSheet({
  required BuildContext context,
  required String title,
  required List<CategoryNode> roots,
}) {
  return showModalBottomSheet<CategoryNode>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFFFBF5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CategoryTreePickerContent(title: title, roots: roots),
  );
}

class _CategoryTreePickerContent extends StatefulWidget {
  const _CategoryTreePickerContent({required this.title, required this.roots});

  final String title;
  final List<CategoryNode> roots;

  @override
  State<_CategoryTreePickerContent> createState() => _CategoryTreePickerContentState();
}

class _CategoryTreePickerContentState extends State<_CategoryTreePickerContent> {
  final List<CategoryNode> _stack = [];

  List<CategoryNode> get _currentList => _stack.isEmpty ? widget.roots : _stack.last.children;

  String get _breadcrumb {
    if (_stack.isEmpty) return widget.title;
    return '${widget.title} • ${_stack.map((e) => e.name).join(' • ')}';
  }

  @override
  Widget build(BuildContext context) {
    final list = _currentList;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _stack.isEmpty
                      ? () => Navigator.of(context).pop()
                      : () => setState(() => _stack.removeLast()),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF241508)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _breadcrumb,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF241508),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFDEDEDE)),
                itemBuilder: (context, index) {
                  final node = list[index];
                  final hasChildren = node.children.isNotEmpty;
                  return ListTile(
                    title: Text(
                      node.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        color: Color(0xFF1E2021),
                      ),
                    ),
                    trailing: hasChildren
                        ? const Icon(Icons.chevron_right, color: Color(0xFF777F84))
                        : const Icon(Icons.check_circle_outline, color: Color(0xFFFDAF40)),
                    onTap: () {
                      if (hasChildren) {
                        setState(() => _stack.add(node));
                      } else {
                        Navigator.of(context).pop(node);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
