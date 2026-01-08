import 'package:flutter/material.dart';

class TribePickerSheet extends StatelessWidget {
  const TribePickerSheet({
    super.key,
    required this.options,
    required this.selected,
  });

  final List<String> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Tap outside area (overlay)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8F1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select tribe',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF241508),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFDEDEDE)),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Color(0xFF241508),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...options.map((t) {
                  final isSelected = t == selected;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(t),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? const Color(0xFFA15E22)
                                : const Color(0xFF777F84),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            t,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF241508),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
