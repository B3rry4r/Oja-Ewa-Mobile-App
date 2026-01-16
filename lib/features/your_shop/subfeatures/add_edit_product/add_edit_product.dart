import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/categories/domain/category_catalog.dart';
import 'package:ojaewa/features/your_shop/presentation/controllers/seller_product_controller.dart';

/// Fetch form options from categories endpoint
final _productFiltersProvider = Provider<CategoryFormOptions>((ref) {
  return ref.watch(categoryFormOptionsProvider);
});

/// Add/Edit Product Screen
/// 
/// Backend form rules:
/// - textiles & shoes_bags: require gender, style, tribe, size
/// - afro_beauty_products: does NOT require gender, style, tribe, size
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({
    super.key, 
    this.productId,
    this.categoryType,
    this.categoryId,
    this.categoryName,
  });

  final String? productId; // If provided, we're editing (string ID from ShopProduct)
  
  /// The category type (textiles, shoes_bags, afro_beauty_products)
  final String? categoryType;
  
  /// The selected category ID from the category picker
  final int? categoryId;
  
  /// The selected category name for display
  final String? categoryName;

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _processingDaysController = TextEditingController(text: '3');

  String? _imagePath;
  String? _selectedStyle;
  String? _selectedTribe;
  String? _selectedFabricType;
  String _processingTimeType = 'normal';
  final List<String> _selectedSizes = [];
  
  // Track category type and ID from navigation
  late String _categoryType;
  late int? _categoryId;
  late String? _categoryName;

  bool get isEditing => widget.productId != null;
  
  /// Whether to show style, tribe, size fields
  /// Required for textiles and shoes_bags
  /// NOT required for afro_beauty_products and art
  bool get _requiresExtendedFields => 
      _categoryType == 'textiles' || _categoryType == 'shoes_bags';
  
  /// Whether to show fabric_type field (Textiles only)
  bool get _requiresFabricType => _categoryType == 'textiles';
  
  
  @override
  void initState() {
    super.initState();
    _categoryType = widget.categoryType ?? 'textiles';
    _categoryId = widget.categoryId;
    _categoryName = widget.categoryName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _processingDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formOptions = ref.watch(_productFiltersProvider);
    final isLoading = ref.watch(sellerProductActionsProvider).isLoading;
    
    // Get category type display name
    final categoryTypeDisplay = switch (_categoryType) {
      'textiles' => 'Textiles',
      'shoes_bags' => 'Shoes & Bags',
      'afro_beauty_products' => 'Beauty Products',
      _ => 'Product',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFFBF5),
              iconColor: const Color(0xFF241508),
              title: Text(
                isEditing ? 'Edit Product' : 'Add $categoryTypeDisplay',
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Product Image Upload
                    _buildImageUpload(),
                    const SizedBox(height: 24),

                    // Product Name
                    _buildTextField(
                      label: 'Product Name',
                      hint: 'Enter product name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),

                    // Category Display (pre-selected from previous screen)
                    _buildCategoryDisplay(),
                    const SizedBox(height: 16),

                    // Fabric Type - ONLY for textiles
                    if (_requiresFabricType) ...[
                      _buildFabricTypePicker(formOptions),
                      const SizedBox(height: 16),
                    ],

                    // Style, Tribe from filters - ONLY for textiles and shoes_bags
                    // Gender removed (Men/Women are now category groups)
                    if (_requiresExtendedFields) ...[
                      _buildFilterDropdowns(formOptions),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    _buildTextField(
                      label: 'Description',
                      hint: 'Enter product description',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // Size Selection - ONLY for textiles and shoes_bags
                    if (_requiresExtendedFields) ...[
                      _buildSizeSelector(),
                      const SizedBox(height: 16),
                    ],

                    // Price
                    _buildTextField(
                      label: 'Price (₦)',
                      hint: 'Enter price',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Discount (optional)
                    _buildTextField(
                      label: 'Discount % (optional)',
                      hint: 'Enter discount percentage',
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Processing Time
                    _buildProcessingTimeSection(),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(isLoading),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    final hasImage = _imagePath != null && _imagePath!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Image',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final path = await pickSingleFilePath();
            if (path != null) setState(() => _imagePath = path);
          },
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFFCCCCCC),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasImage ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 40,
                  color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFF777F84),
                ),
                const SizedBox(height: 12),
                Text(
                  hasImage ? 'Image selected' : 'Tap to upload image',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    color: hasImage ? const Color(0xFF4CAF50) : const Color(0xFF1E2021),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'JPG, PNG (max 5MB)',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    color: Color(0xFF777F84),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                color: Color(0xFFCCCCCC),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownPlaceholder(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: Color(0xFFCCCCCC),
            ),
          ),
        ),
      ],
    );
  }

  /// Displays the pre-selected category (from category selection screen)
  /// with option to change it via the category tree picker
  Widget _buildCategoryDisplay() {
    final displayName = _categoryName ?? 'Select category';
    final hasCategory = _categoryId != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            // Allow changing category within the same type
            final catalog = await ref.read(allCategoriesProvider.future);
            if (!mounted) return;
            
            final roots = catalog.categories[_categoryType] ?? [];
            if (roots.isEmpty) return;
            
            final selected = await showCategoryTreePickerSheet(
              context: context,
              title: 'Select Category',
              roots: roots,
            );
            if (selected != null) {
              setState(() {
                _categoryId = selected.id;
                _categoryName = selected.name;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      color: hasCategory ? const Color(0xFF1E2021) : const Color(0xFFCCCCCC),
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdowns(CategoryFormOptions filters) {
    return Column(
      children: [
        _buildDropdown(
          label: 'Style',
          value: _selectedStyle,
          items: filters.styles,
          onChanged: (v) => setState(() => _selectedStyle = v),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Tribe',
          value: _selectedTribe,
          items: filters.tribes,
          onChanged: (v) => setState(() => _selectedTribe = v),
        ),
      ],
    );
  }

  Widget _buildFabricTypePicker(CategoryFormOptions options) {
    return _buildDropdown(
      label: 'Fabric Type',
      value: _selectedFabricType,
      items: options.fabrics,
      onChanged: (v) => setState(() => _selectedFabricType = v),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (items.isEmpty) return;
            final selected = await SelectionBottomSheet.show(
              context,
              title: label,
              options: items,
              selected: value ?? '',
            );
            if (selected != null) {
              onChanged(selected);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value?.isNotEmpty == true ? value! : 'Select $label',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      color: value?.isNotEmpty == true ? const Color(0xFF1E2021) : const Color(0xFFCCCCCC),
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF777F84)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Sizes',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((size) {
            final isSelected = _selectedSizes.contains(size);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSizes.remove(size);
                  } else {
                    _selectedSizes.add(size);
                  }
                });
              },
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFDAF40) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFFCCCCCC),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF1E2021),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProcessingTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Processing Time',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _processingTimeType = 'normal'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _processingTimeType == 'normal'
                        ? const Color(0xFFFDAF40)
                        : Colors.transparent,
                    border: Border.all(
                      color: _processingTimeType == 'normal'
                          ? const Color(0xFFFDAF40)
                          : const Color(0xFFCCCCCC),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Normal',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w500,
                        color: _processingTimeType == 'normal'
                            ? Colors.white
                            : const Color(0xFF1E2021),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _processingTimeType = 'quick'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _processingTimeType == 'quick'
                        ? const Color(0xFFFDAF40)
                        : Colors.transparent,
                    border: Border.all(
                      color: _processingTimeType == 'quick'
                          ? const Color(0xFFFDAF40)
                          : const Color(0xFFCCCCCC),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Quick',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w500,
                        color: _processingTimeType == 'quick'
                            ? Colors.white
                            : const Color(0xFF1E2021),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Processing Days',
          hint: 'Enter number of days',
          controller: _processingDaysController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _submitProduct,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFFBF5),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing ? 'Update Product' : 'Add Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFBF5),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _submitProduct() async {
    // Validate common fields
    if (_imagePath == null || _imagePath!.isEmpty) {
      AppSnackbars.showError(context, 'Please upload a product image');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Please enter product name');
      return;
    }
    if (_categoryId == null) {
      AppSnackbars.showError(context, 'Please select a category');
      return;
    }
    
    // Validate fabric_type for textiles only
    if (_requiresFabricType) {
      if (_selectedFabricType == null) {
        AppSnackbars.showError(context, 'Please select a fabric type');
        return;
      }
    }
    
    // Validate extended fields only for textiles and shoes_bags
    if (_requiresExtendedFields) {
      if (_selectedStyle == null) {
        AppSnackbars.showError(context, 'Please select a style');
        return;
      }
      if (_selectedTribe == null) {
        AppSnackbars.showError(context, 'Please select a tribe');
        return;
      }
      if (_selectedSizes.isEmpty) {
        AppSnackbars.showError(context, 'Please select at least one size');
        return;
      }
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Please enter product description');
      return;
    }
    final price = num.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      AppSnackbars.showError(context, 'Please enter a valid price');
      return;
    }
    final processingDays = int.tryParse(_processingDaysController.text.trim());
    if (processingDays == null || processingDays <= 0) {
      AppSnackbars.showError(context, 'Please enter valid processing days');
      return;
    }

    final discount = int.tryParse(_discountController.text.trim());

    try {
      if (isEditing) {
        final productIdInt = int.tryParse(widget.productId!) ?? 0;
        await ref.read(sellerProductActionsProvider.notifier).updateProduct(
              productId: productIdInt,
              categoryId: _categoryId!,
              name: _nameController.text.trim(),
              // Only pass extended fields if required
              style: _requiresExtendedFields ? _selectedStyle : null,
              tribe: _requiresExtendedFields ? _selectedTribe : null,
              fabricType: _requiresFabricType ? _selectedFabricType : null,
              description: _descriptionController.text.trim(),
              imagePath: _imagePath,
              sizes: _requiresExtendedFields ? _selectedSizes : null,
              processingTimeType: _processingTimeType,
              processingDays: processingDays,
              price: price,
              discount: discount,
            );
        if (mounted) {
          AppSnackbars.showSuccess(context, 'Product updated successfully');
          Navigator.of(context).pop(true);
        }
      } else {
        await ref.read(sellerProductActionsProvider.notifier).createProduct(
              categoryId: _categoryId!,
              name: _nameController.text.trim(),
              // Only pass extended fields if required
              style: _requiresExtendedFields ? _selectedStyle : null,
              tribe: _requiresExtendedFields ? _selectedTribe : null,
              fabricType: _requiresFabricType ? _selectedFabricType : null,
              description: _descriptionController.text.trim(),
              imagePath: _imagePath!,
              sizes: _requiresExtendedFields ? _selectedSizes : null,
              processingTimeType: _processingTimeType,
              processingDays: processingDays,
              price: price,
              discount: discount,
            );
        if (mounted) {
          AppSnackbars.showSuccess(context, 'Product added successfully');
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Failed: ${e.toString()}');
      }
    }
  }
}
