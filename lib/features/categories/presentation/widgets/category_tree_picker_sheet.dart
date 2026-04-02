import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
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
  final colors = context.appColors;
  return showModalBottomSheet<CategoryNode>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surfaceElevated,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: colors.border),
    ),
    builder: (_) => _CategoryTreePickerContent(title: title, roots: roots),
  );
}

class _CategoryTreePickerContent extends StatefulWidget {
  const _CategoryTreePickerContent({required this.title, required this.roots});

  final String title;
  final List<CategoryNode> roots;

  @override
  State<_CategoryTreePickerContent> createState() =>
      _CategoryTreePickerContentState();
}

class _CategoryTreePickerContentState
    extends State<_CategoryTreePickerContent> {
  final List<CategoryNode> _stack = [];

  List<CategoryNode> get _currentList =>
      _stack.isEmpty ? widget.roots : _stack.last.children;

  String get _breadcrumb {
    if (_stack.isEmpty) return widget.title;
    return '${widget.title} • ${_stack.map((e) => e.name).join(' • ')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                  icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _breadcrumb,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
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
                separatorBuilder: (context, index) =>
                    Divider(color: colors.border),
                itemBuilder: (context, index) {
                  final node = list[index];
                  final hasChildren = node.children.isNotEmpty;
                  return ListTile(
                    title: Text(
                      node.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        color: colors.textPrimary,
                      ),
                    ),
                    trailing: hasChildren
                        ? Icon(Icons.chevron_right, color: colors.textTertiary)
                        : Icon(
                            Icons.check_circle_outline,
                            color: colors.accent,
                          ),
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
