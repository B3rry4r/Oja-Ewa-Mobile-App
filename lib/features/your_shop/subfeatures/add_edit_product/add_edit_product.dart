import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/categories/presentation/controllers/category_controller.dart';
import 'package:ojaewa/features/categories/presentation/widgets/category_tree_picker_sheet.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/categories/domain/category_catalog.dart';
import 'package:ojaewa/features/categories/domain/category_node.dart';
import 'package:ojaewa/features/product/data/product_repository_impl.dart';
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
    this.initialName,
    this.initialDescription,
    this.initialStyle,
    this.initialTribe,
    this.initialSizes,
    this.initialPrice,
  });

  final String?
  productId; // If provided, we're editing (string ID from ShopProduct)

  /// The category type (textiles, shoes_bags, afro_beauty_products)
  final String? categoryType;

  /// The selected category ID from the category picker
  final int? categoryId;

  /// The selected category name for display
  final String? categoryName;

  /// Seed values already known from the ShopProduct being edited. These are
  /// shown immediately (before the details fetch completes) and act as a
  /// fallback if that fetch fails, so the form is never fully blank.
  final String? initialName;
  final String? initialDescription;
  final String? initialStyle;
  final String? initialTribe;
  final List<String>? initialSizes;
  final String? initialPrice;

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _processingDaysController = TextEditingController(text: '3');

  String? _imagePath;

  /// Existing hosted image URL when editing (so the seller isn't forced to
  /// re-upload). Counts as a valid image on submit.
  String? _existingImageUrl;

  /// True while the existing product is being fetched for editing.
  bool _loading = false;

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

  /// Whether to show style, tribe, size, gender fields
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

    if (isEditing) {
      // Seed with what we already know from the ShopProduct so the form isn't
      // blank while (and if) the details fetch is in flight/fails.
      if (widget.initialName != null) _nameController.text = widget.initialName!;
      if (widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
      if (widget.initialPrice != null && widget.initialPrice!.isNotEmpty) {
        _priceController.text = widget.initialPrice!;
      }
      if (widget.initialStyle != null && widget.initialStyle!.isNotEmpty) {
        _selectedStyle = widget.initialStyle;
      }
      if (widget.initialTribe != null && widget.initialTribe!.isNotEmpty) {
        _selectedTribe = widget.initialTribe;
      }
      if (widget.initialSizes != null) {
        _selectedSizes.addAll(widget.initialSizes!);
      }
      _loadProduct();
    }
  }

  /// Fetch the existing product and populate the form so editing doesn't force
  /// a full re-entry (including re-uploading the image).
  Future<void> _loadProduct() async {
    final id = int.tryParse(widget.productId!);
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final json = await ref
          .read(productRepositoryProvider)
          .getProductDetails(id);

      // Resolve category type/name from the category id via the catalog, since
      // the details response only carries the numeric category id.
      final categoryId = _asInt(json['category_id']) ??
          _asInt((json['category'] as Map<String, dynamic>?)?['id']);
      if (categoryId != null) {
        final catalog = await ref.read(allCategoriesProvider.future);
        final match = _findCategory(catalog, categoryId);
        if (match != null) {
          _categoryType = match.type;
          _categoryName = match.name;
        }
        _categoryId = categoryId;
      }

      // Basic fields
      _nameController.text = (json['name'] as String?) ?? '';
      _descriptionController.text = (json['description'] as String?) ?? '';
      final price = json['price'];
      if (price != null) _priceController.text = price.toString();

      final processingDays = _asInt(json['processing_days']);
      if (processingDays != null) {
        _processingDaysController.text = processingDays.toString();
      }
      final processingType = json['processing_time_type'] as String?;
      if (processingType != null && processingType.isNotEmpty) {
        _processingTimeType = processingType;
      }

      // Shipping dimensions
      final weight = json['weight_kg'];
      if (weight != null) _weightController.text = weight.toString();
      final length = json['length_cm'];
      if (length != null) _lengthController.text = length.toString();
      final width = json['width_cm'];
      if (width != null) _widthController.text = width.toString();
      final height = json['height_cm'];
      if (height != null) _heightController.text = height.toString();

      // Category-specific fields
      final style = json['style'] as String?;
      if (style != null && style.isNotEmpty) _selectedStyle = style;
      final tribe = json['tribe'] as String?;
      if (tribe != null && tribe.isNotEmpty) _selectedTribe = tribe;
      final fabricType = json['fabric_type'] as String?;
      if (fabricType != null && fabricType.isNotEmpty) {
        _selectedFabricType = fabricType;
      }

      // Sizes: API sends a comma-separated string under "size"
      final sizeRaw = json['size'] ?? json['sizes'];
      _selectedSizes
        ..clear()
        ..addAll(_parseSizes(sizeRaw));

      // Existing hosted image so re-upload isn't required
      final image = json['image'] as String?;
      if (image != null && image.isNotEmpty) _existingImageUrl = image;

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppSnackbars.showError(context, 'Failed to load product: ${e.toString()}');
      }
    }
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  List<String> _parseSizes(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  /// Depth-first search across all category types for a node with [id].
  CategoryNode? _findCategory(CategoryCatalog catalog, int id) {
    CategoryNode? search(List<CategoryNode> nodes) {
      for (final node in nodes) {
        if (node.id == id) return node;
        final child = search(node.children);
        if (child != null) return child;
      }
      return null;
    }

    for (final roots in catalog.categories.values) {
      final found = search(roots);
      if (found != null) return found;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _processingDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final formOptions = ref.watch(_productFiltersProvider);
    final isLoading = ref.watch(sellerProductActionsProvider).isLoading;

    // Get category type display name
    final categoryTypeDisplay = switch (_categoryType) {
      'textiles' => 'Textiles',
      'shoes_bags' => 'Shoes & Bags',
      'afro_beauty_products' => 'Beauty Products',
      _ => 'Product',
    };

    if (_loading) {
      return AppPageScaffold(
        title: isEditing ? 'Edit Product' : 'Add $categoryTypeDisplay',
        child: const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AppPageScaffold(
      title: isEditing ? 'Edit Product' : 'Add $categoryTypeDisplay',
      scrollable: true,
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

          // AI Description Generator
          /*
                    if (_requiresExtendedFields) ...[
                      AiDescriptionGenerator(
                        nameController: _nameController,
                        priceController: _priceController,
                        descriptionController: _descriptionController,
                        style: _selectedStyle,
                        tribe: _selectedTribe,
                        gender: 'unisex',
                        materials: _selectedFabricType,
                        occasion: null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    */

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

          // Shipping Dimensions (New)
          Text(
            'Shipping Dimensions (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Weight (kg)',
            hint: 'e.g. 0.5',
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Length (cm)',
                  hint: '30',
                  controller: _lengthController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Width (cm)',
                  hint: '20',
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Height (cm)',
                  hint: '10',
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
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
    );
  }

  Widget _buildImageUpload() {
    final colors = context.appColors;
    final hasNewImage = _imagePath != null && _imagePath!.isNotEmpty;
    final hasExistingImage =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;
    final hasImage = hasNewImage || hasExistingImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Image',
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
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
                color: hasImage ? const Color(0xFF4CAF50) : colors.border,
              ),
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: hasExistingImage && !hasNewImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      _existingImageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasImage
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 40,
                        color: hasImage
                            ? const Color(0xFF4CAF50)
                            : colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hasImage ? 'Image selected' : 'Tap to upload image',
                        style: TextStyle(
                          fontSize: 16,
                          color: hasImage
                              ? const Color(0xFF4CAF50)
                              : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG (max 5MB)',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
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
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                color: colors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  /// Displays the pre-selected category (from category selection screen)
  /// with option to change it via the category tree picker
  Widget _buildCategoryDisplay() {
    final colors = context.appColors;
    final displayName = _categoryName ?? 'Select category';
    final hasCategory = _categoryId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
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
              color: colors.surface,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      color: hasCategory
                          ? colors.textPrimary
                          : colors.textTertiary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
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
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
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
              color: colors.surface,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value?.isNotEmpty == true ? value! : 'Select $label',
                    style: TextStyle(
                      fontSize: 16,
                      color: value?.isNotEmpty == true
                          ? colors.textPrimary
                          : colors.textTertiary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final colors = context.appColors;
    final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Sizes',
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
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
                  color: isSelected ? colors.accent : colors.surface,
                  border: Border.all(
                    color: isSelected ? colors.accent : colors.border,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? colors.onAccent : colors.textPrimary,
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
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Processing Time',
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
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
                        ? colors.accent
                        : colors.surface,
                    border: Border.all(
                      color: _processingTimeType == 'normal'
                          ? colors.accent
                          : colors.border,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Normal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _processingTimeType == 'normal'
                            ? colors.onAccent
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _processingTimeType = 'quick_quick'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _processingTimeType == 'quick_quick'
                        ? colors.accent
                        : colors.surface,
                    border: Border.all(
                      color: _processingTimeType == 'quick_quick'
                          ? colors.accent
                          : colors.border,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Quick Quick',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _processingTimeType == 'quick_quick'
                            ? colors.onAccent
                            : colors.textPrimary,
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
    final colors = context.appColors;
    return GestureDetector(
      onTap: isLoading ? null : _submitProduct,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
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
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing ? 'Update Product' : 'Add Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onAccent,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _submitProduct() async {
    // Validate common fields. On edit, an already-hosted image URL counts as a
    // valid image so the seller isn't forced to re-upload.
    final hasNewImage = _imagePath != null && _imagePath!.isNotEmpty;
    final hasExistingImage =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;
    if (!hasNewImage && !hasExistingImage) {
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

    try {
      if (isEditing) {
        final productIdInt = int.tryParse(widget.productId!) ?? 0;
        await ref
            .read(sellerProductActionsProvider.notifier)
            .updateProduct(
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
              weightKg: num.tryParse(_weightController.text.trim()),
              lengthCm: num.tryParse(_lengthController.text.trim()),
              widthCm: num.tryParse(_widthController.text.trim()),
              heightCm: num.tryParse(_heightController.text.trim()),
            );

        // Upload image if provided
        if (_imagePath != null && _imagePath!.isNotEmpty) {
          try {
            await ref
                .read(sellerProductActionsProvider.notifier)
                .uploadProductImage(
                  productId: productIdInt,
                  filePath: _imagePath!,
                );
          } catch (e) {
            // Image upload failed but product was updated - show warning
            if (mounted) {
              AppSnackbars.showError(
                context,
                'Product updated but image upload failed',
              );
            }
          }
        }

        if (mounted) {
          AppSnackbars.showSuccess(context, 'Product updated successfully');
          Navigator.of(context).pop(true);
        }
      } else {
        final result = await ref
            .read(sellerProductActionsProvider.notifier)
            .createProduct(
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
              weightKg: num.tryParse(_weightController.text.trim()),
              lengthCm: num.tryParse(_lengthController.text.trim()),
              widthCm: num.tryParse(_widthController.text.trim()),
              heightCm: num.tryParse(_heightController.text.trim()),
            );

        // Upload image if provided - get product ID from result
        final productId =
            result['product']?['id'] as int? ?? result['id'] as int?;
        if (_imagePath != null && _imagePath!.isNotEmpty && productId != null) {
          try {
            await ref
                .read(sellerProductActionsProvider.notifier)
                .uploadProductImage(
                  productId: productId,
                  filePath: _imagePath!,
                );
          } catch (e) {
            // Image upload failed but product was created - show warning
            if (mounted) {
              AppSnackbars.showError(
                context,
                'Product created but image upload failed',
              );
            }
          }
        }

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
