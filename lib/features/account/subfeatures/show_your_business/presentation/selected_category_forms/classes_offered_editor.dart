import 'package:flutter/material.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';

class ClassOfferedItem {
  ClassOfferedItem({this.name = '', this.duration = ''});

  String name;
  String duration;

  Map<String, dynamic> toJson() => {'name': name, 'duration': duration};
}

/// UI-only editor for classes_offered canonical JSON:
/// [ {"name": "Beginner Makeup", "duration": "4 weeks"}, ... ]
class ClassesOfferedEditor extends StatefulWidget {
  const ClassesOfferedEditor({super.key, required this.items});

  final List<ClassOfferedItem> items;

  @override
  State<ClassesOfferedEditor> createState() => _ClassesOfferedEditorState();
}

class _ClassesOfferedEditorState extends State<ClassesOfferedEditor> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          _Row(
            item: widget.items[i],
            onRemove: widget.items.length <= 1
                ? null
                : () => setState(() => widget.items.removeAt(i)),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => setState(() => widget.items.add(ClassOfferedItem())),
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
                'Add class',
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

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onRemove});

  final ClassOfferedItem item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: _TextBox(
            label: 'Class name',
            hint: 'e.g. Beginner Makeup',
            onChanged: (v) => item.name = v,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TextBox(
            label: 'Duration',
            hint: 'e.g. 4 weeks',
            onChanged: (v) => item.duration = v,
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

class _TextBox extends StatelessWidget {
  const _TextBox({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}
