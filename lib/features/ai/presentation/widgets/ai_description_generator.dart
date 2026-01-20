import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/ai_description_controller.dart';

/// AI Description Generator Widget
/// 
/// A reusable widget that can be embedded in product creation/edit screens
/// to generate AI-powered product descriptions.
class AiDescriptionGenerator extends ConsumerStatefulWidget {
  const AiDescriptionGenerator({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.descriptionController,
    required this.style,
    required this.tribe,
    required this.gender,
    this.materials,
    this.occasion,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final String? style;
  final String? tribe;
  final String gender;
  final String? materials;
  final String? occasion;

  @override
  ConsumerState<AiDescriptionGenerator> createState() =>
      _AiDescriptionGeneratorState();
}

class _AiDescriptionGeneratorState
    extends ConsumerState<AiDescriptionGenerator> {
  bool _isExpanded = false;

  double? get _priceValue {
    final value = double.tryParse(widget.priceController.text);
    return value != null && value > 0 ? value : null;
  }

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_handleInputChange);
    widget.priceController.addListener(_handleInputChange);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_handleInputChange);
    widget.priceController.removeListener(_handleInputChange);
    super.dispose();
  }

  void _handleInputChange() {
    if (mounted) setState(() {});
  }

  bool get _canGenerate {
    return widget.nameController.text.isNotEmpty &&
        widget.style != null &&
        widget.tribe != null &&
        _priceValue != null;
  }

  Future<void> _generateDescription() async {
    if (!_canGenerate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in name, style, tribe, and price first'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
      return;
    }

    final description = await ref
        .read(aiDescriptionControllerProvider.notifier)
        .generateDescription(
          name: widget.nameController.text,
          style: widget.style!,
          tribe: widget.tribe!,
          gender: widget.gender,
          price: _priceValue!,
          materials: widget.materials,
          occasion: widget.occasion,
        );

    if (description != null && mounted) {
      widget.descriptionController.text = description.description;
      setState(() => _isExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(aiDescriptionControllerProvider);
    final state = stateAsync.value ?? const AiDescriptionState();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDAF40).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDAF40).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFDAF40),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Description Generator',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                        Text(
                          'Generate culturally-rich product descriptions',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Campton',
                            color: const Color(0xFF241508).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF777F84),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicators
                  _buildStatusItem(
                    'Product Name',
                    widget.nameController.text.isNotEmpty,
                    widget.nameController.text.isEmpty
                        ? 'Required'
                        : widget.nameController.text,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusItem(
                    'Style',
                    widget.style != null && widget.style!.isNotEmpty,
                    widget.style ?? 'Required',
                  ),
                  const SizedBox(height: 8),
                  _buildStatusItem(
                    'Tribe/Culture',
                    widget.tribe != null && widget.tribe!.isNotEmpty,
                    widget.tribe ?? 'Required',
                  ),
                  const SizedBox(height: 8),
                  _buildStatusItem(
                    'Price',
                    _priceValue != null,
                    _priceValue != null ? '₦${_priceValue!.toStringAsFixed(0)}' : 'Required',
                  ),
                  const SizedBox(height: 8),
                  _buildStatusItem(
                    'Materials',
                    widget.materials != null && widget.materials!.isNotEmpty,
                    widget.materials ?? 'Optional',
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (state.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, 
                              color: Color(0xFFE57373), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Campton',
                                color: Color(0xFFE57373),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading ? null : _generateDescription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDAF40),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: const Color(0xFFCCCCCC),
                      ),
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 20),
                      label: Text(
                        state.isLoading
                            ? 'Generating...'
                            : 'Generate Description',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'The AI will create a description using Nigerian fashion terminology and cultural context.',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Campton',
                      color: const Color(0xFF241508).withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isComplete, String value) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFFCCCCCC),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w500,
            color: Color(0xFF777F84),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Campton',
              color: isComplete
                  ? const Color(0xFF241508)
                  : const Color(0xFFCCCCCC),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
