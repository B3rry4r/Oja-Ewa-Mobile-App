import 'package:flutter/material.dart';

/// A professional bottom sheet modal for displaying product details.
/// Package: ojaewa
class ProductDescriptionBottomSheet extends StatelessWidget {
  const ProductDescriptionBottomSheet({super.key});

  /// Static helper to show the bottom sheet with the requested dark barrier
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7), // Requirement: 0.7 opacity dark barrier
      builder: (context) => const ProductDescriptionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F1), // Background from IR: #fff8f1
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
            // Drag Handle for UX
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header Row: Title and Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Description', // "Decription" typo from IR corrected
                    style: TextStyle(
                      fontFamily: 'Campton',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF301C0A), // #301c0a
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
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF301C0A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFDEDEDE), thickness: 0.5),

            // Content Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SingleChildScrollView(
                child: Text(
                  'Fully lined agbada\n'
                  'Made from quality ankara fabric\n'
                  'Neat Finishing\n'
                  'Safe to wash\n'
                  'Weight 20g',
                  style: TextStyle(
                    fontFamily: 'Campton',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF3C4042), // #3c4042
                    height: 1.6, // Improved line height for readability
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}