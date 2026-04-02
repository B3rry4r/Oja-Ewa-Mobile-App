import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';

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
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
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
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Change Size',
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, size: 20, color: colors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agbada in Vogue', // Corrected "Voue" typo from IR
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'by Jenny Stitches',
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeLabelRow() {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Size',
          style: TextStyle(
            fontFamily: 'Campton',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () {
            /* Open Size Chart */
          },
          child: Text(
            'View Size Chart',
            style: TextStyle(
              fontFamily: 'Campton',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final colors = context.appColors;
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
              color: isSelected ? colors.accent : Colors.transparent,
              border: isSelected ? null : Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              size,
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isSelected ? colors.onAccent : colors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpdateButton() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.4),
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
          child: Center(
            child: Text(
              'Update Size',
              style: TextStyle(
                fontFamily: 'Campton',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
