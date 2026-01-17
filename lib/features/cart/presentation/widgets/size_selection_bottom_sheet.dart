import 'package:flutter/material.dart';

/// A Bottom Sheet for selecting product sizes.
/// Package: ojaewa
class SizeSelectionBottomSheet extends StatefulWidget {
  const SizeSelectionBottomSheet({super.key, required this.initialSize});

  final String initialSize;

  /// Shows the modal and returns the selected size when the user taps "Update".
  static Future<String?> show(
    BuildContext context, {
    required String initialSize,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => SizeSelectionBottomSheet(initialSize: initialSize),
    );
  }

  @override
  State<SizeSelectionBottomSheet> createState() =>
      _SizeSelectionBottomSheetState();
}

class _SizeSelectionBottomSheetState extends State<SizeSelectionBottomSheet> {
  late String selectedSize;
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    selectedSize = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1), // IR: #fff8f1
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildProductInfo(),
            const SizedBox(height: 24),
            _buildSizeLabelRow(),
            const SizedBox(height: 12),
            _buildSizeSelector(),
            const SizedBox(height: 48),
            _buildUpdateButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Change Size',
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF301C0A), // IR: #301c0a
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.close, size: 20, color: Color(0xFF301C0A)),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Agbada in Vogue', // Corrected "Voue" typo from IR
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF595F63), // IR: #595f63
          ),
        ),
        SizedBox(height: 4),
        Text(
          'by Jenny Stitches',
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF595F63),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeLabelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Size',
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E2021),
          ),
        ),
        GestureDetector(
          onTap: () {
            /* Open Size Chart */
          },
          child: const Text(
            'View Size Chart',
            style: TextStyle(
              fontFamily: 'Campton',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF777F84),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 12,
      children: sizes.map((size) {
        bool isSelected = selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => selectedSize = size),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
              border: isSelected
                  ? null
                  : Border.all(color: const Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              size,
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white : const Color(0xFF1E2021),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40), // IR: #fdaf40
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, selectedSize),
          borderRadius: BorderRadius.circular(8),
          child: const Center(
            child: Text(
              'Update Size',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
