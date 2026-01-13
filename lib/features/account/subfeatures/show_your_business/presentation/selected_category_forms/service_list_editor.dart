import 'package:flutter/material.dart';

class ServiceListItem {
  ServiceListItem({this.name = '', this.priceRange = ''});

  String name;
  String priceRange;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price_range': priceRange,
      };
}

/// UI-only editor for service_list canonical JSON:
/// [ {"name": "Hair Styling", "price_range": "₦5,000 - ₦15,000"}, ... ]
class ServiceListEditor extends StatefulWidget {
  const ServiceListEditor({super.key, required this.items});

  final List<ServiceListItem> items;

  @override
  State<ServiceListEditor> createState() => _ServiceListEditorState();
}

class _ServiceListEditorState extends State<ServiceListEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          _ServiceRow(
            item: widget.items[i],
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
            onTap: () => setState(() => widget.items.add(ServiceListItem())),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDAF40),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Add service',
                style: TextStyle(
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFBF5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.item, required this.onRemove});

  final ServiceListItem item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TextBox(
            label: 'Service name',
            hint: 'e.g. Hair Styling',
            onChanged: (v) => item.name = v,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TextBox(
            label: 'Price range',
            hint: '₦5,000 - ₦15,000',
            onChanged: (v) => item.priceRange = v,
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF777F84)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF777F84), fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            color: Color(0xFF1E2021),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFDAF40)),
            ),
          ),
        ),
      ],
    );
  }
}
