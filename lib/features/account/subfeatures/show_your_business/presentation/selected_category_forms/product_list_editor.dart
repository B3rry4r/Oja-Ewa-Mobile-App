import 'package:flutter/material.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';

/// UI-only editor for product_list canonical JSON:
/// [ "Product 1", "Product 2", ... ]
class ProductListEditor extends StatefulWidget {
  const ProductListEditor({super.key, required this.items});

  final List<String> items;

  @override
  State<ProductListEditor> createState() => _ProductListEditorState();
}

class _ProductListEditorState extends State<ProductListEditor> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          _ProductRow(
            index: i,
            value: widget.items[i],
            onChanged: (v) => widget.items[i] = v,
            onRemove: widget.items.length <= 1
                ? null
                : () {
                    setState(() => widget.items.removeAt(i));
                  },
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => setState(() => widget.items.add('')),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                'Add product',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: colors.onAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.index,
    required this.value,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey(index),
            initialValue: value,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Campton',
              fontSize: 16,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Ankara Fabric',
              hintStyle: TextStyle(color: colors.textTertiary),
              filled: true,
              fillColor: colors.surfaceElevated,
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: colors.accent),
              ),
            ),
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 18, color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
