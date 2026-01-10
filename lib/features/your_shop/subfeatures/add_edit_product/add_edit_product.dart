import 'package:flutter/material.dart';

import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/your_shop/subfeatures/add_edit_product/tribe_picker_sheet.dart';

import '../product/domain/shop_product.dart';
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key, this.initialProduct});

  /// If provided, screen is in edit mode and fields are prefilled.
  final ShopProduct? initialProduct;

  bool get isEdit => initialProduct != null;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Local state for interactive elements
  late String selectedGender;
  late String selectedStyle;
  late List<String> selectedSizes;

  late final TextEditingController _name;
  late final TextEditingController _description;
  late String selectedTribe;

  late final TextEditingController _normalDays;
  late final TextEditingController _normalPrice;
  late final TextEditingController _quickDays;
  late final TextEditingController _quickPrice;

  String? selectedDiscount;

  @override
  void initState() {
    super.initState();

    final p = widget.initialProduct;
    selectedGender = p?.gender ?? 'Men';
    selectedStyle = p?.style ?? 'Shirts';
    selectedTribe = p?.tribe ?? 'Select tribe';
    selectedSizes = List<String>.from(p?.sizes ?? const ['M']);

    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');

    _normalDays = TextEditingController(text: p?.normalDays ?? '');
    _normalPrice = TextEditingController(text: p?.normalPrice ?? '');
    _quickDays = TextEditingController(text: p?.quickDays ?? '');
    _quickPrice = TextEditingController(text: p?.quickPrice ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _normalDays.dispose();
    _normalPrice.dispose();
    _quickDays.dispose();
    _quickPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Main background from IR
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildSectionTitle(
                widget.isEdit ? "Edit Product" : "Add Product",
                fontSize: 33,
                color: const Color(0xFF241508),
              ),
              const SizedBox(height: 20),

              // Product Name Input
              _buildLabel("Name"),
              _buildTextField(controller: _name, hintText: "Name of product"),

              const SizedBox(height: 24),

              // Gender Selection
              _buildLabel("What gender is your product?"),
              _buildGenderSelection(),

              const SizedBox(height: 24),

              // Style Selection
              _buildLabel("Choose one style"),
              _buildStyleChips(),

              const SizedBox(height: 24),

              // Tribe Dropdown
              _buildLabel("What tribe is our product?"),
              _buildTribeDropdown(),

              const SizedBox(height: 24),

              // Description
              _buildLabel("Description"),
              _buildTextField(
                controller: _description,
                hintText: "List your product features and benefits",
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // Image Upload Section
              _buildLabel("Upload product images"),
              _buildUploadPlaceholder(),

              const SizedBox(height: 24),

              // Size Selection
              _buildLabel("Select available sizes"),
              _buildSizeSelector(),

              const SizedBox(height: 32),

              // Processing Time & Price Section
              const Text(
                "Processing Time/Price",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4042),
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 16),
              _buildPriceRow("Normal"),
              const SizedBox(height: 24),
              _buildPriceRow("Quick Quick"),

              const SizedBox(height: 24),

              // Discount Section
              _buildLabel("Add Discount (Optional)"),
              _buildDiscountChips(),

              const SizedBox(height: 40),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircularButton(Icons.arrow_back_ios_new),
        _buildCircularButton(Icons.close),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF241508)),
    );
  }

  Widget _buildSectionTitle(String text, {double fontSize = 14, Color? color}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? const Color(0xFF777F84),
        fontFamily: 'Campton',
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF777F84),
          fontFamily: 'Campton',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFDAF40)),
        ),
      ),
    );
  }

  Widget _buildTribeDropdown() {
    // This is intentionally a custom picker (bottom sheet), not a native dropdown.
    // TODO: Replace with backend-driven list later.
    const tribes = <String>['Yoruba', 'Igbo', 'Hausa', 'Edo', 'Ijaw'];

    final hasValue = tribes.contains(selectedTribe);

    return InkWell(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          // Match Sort overlay: dim the background but keep it visible.
          barrierColor: Colors.black.withOpacity(0.7),
          isScrollControlled: true,
          builder: (_) => TribePickerSheet(
            options: tribes,
            selected: hasValue ? selectedTribe : null,
          ),
        );

        if (selected != null) {
          setState(() => selectedTribe = selected);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hasValue ? selectedTribe : 'Select tribe',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: hasValue ? const Color(0xFF241508) : const Color(0xFFCCCCCC),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
          ],
        ),
      ),
    );
  }


  Widget _buildGenderSelection() {
    return Column(
      children: [
        _genderTile("Men", Icons.male, selectedGender == "Men"),
        const SizedBox(height: 8),
        _genderTile("Women", Icons.female, selectedGender == "Women"),
      ],
    );
  }

  Widget _genderTile(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = title),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected
                ? const Color(0xFFA15E22)
                : const Color(0xFF777F84),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF241508)),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChips() {
    final styles = ["Shirts", "Dress", "Trouser", "Up and down"];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: styles.map((style) {
        final isSelected = selectedStyle == style;

        return InkWell(
          onTap: () => setState(() => selectedStyle = style),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              // No fill; keep it like the textfields.
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF603814)
                    : const Color(0xFFCCCCCC),
              ),
            ),
            child: Text(
              style,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF241508),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF89858A),
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: AppImagePlaceholder(
          width: 96,
          height: 96,
          borderRadius: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    final sizes = ["XS", "S", "M", "L", "XL"];
    return Row(
      children: sizes.map((size) {
        final isSelected = selectedSizes.contains(size);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? selectedSizes.remove(size) : selectedSizes.add(size);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF603814) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1E2021),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRow(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF595F63),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _normalDays,
                hintText: "Input days",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _normalPrice,
                hintText: "N 5,000",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscountChips() {
    final discounts = ["5%", "10%", "15%", "20%"];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: discounts.map((d) {
        final isSelected = selectedDiscount == d;

        return InkWell(
          onTap: () {
            setState(() {
              selectedDiscount = isSelected ? null : d;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF603814) : const Color(0xFFCCCCCC),
              ),
              color: isSelected ? const Color(0xFF603814) : Colors.transparent,
            ),
            child: Text(
              d,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF1E2021),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    final label = widget.isEdit ? 'Save Changes' : 'Send for review';

    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
