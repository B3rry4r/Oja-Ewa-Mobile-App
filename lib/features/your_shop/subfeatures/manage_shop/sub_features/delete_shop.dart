import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';

import '../../../../../core/widgets/confirmation_modal.dart';

class DeleteShopScreen extends ConsumerStatefulWidget {
  const DeleteShopScreen({super.key});

  @override
  ConsumerState<DeleteShopScreen> createState() => _DeleteShopScreenState();
}

class _DeleteShopScreenState extends ConsumerState<DeleteShopScreen> {
  bool _isDeleting = false;
  // Local state to track selected reason
  String? selectedReason;

  final List<String> reasons = [
    "Not making money",
    "Switching to another platform",
    "Technical issues",
    "Too expensive",
    "Other"
  ];

  Future<void> _deleteShop() async {
    if (selectedReason == null || _isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(sellerStatusApiProvider).deleteSellerProfile(reason: selectedReason);
      
      // Invalidate the seller status provider to refresh state
      ref.invalidate(mySellerStatusProvider);
      
      if (mounted) {
        AppSnackbars.showSuccess(context, 'Shop deleted successfully');
        // Navigate back to home
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, 'Failed to delete shop: $e');
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard App Header
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
              
              // Title: Why are you leaving
              const Text(
                "Why are you leaving",
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                  fontFamily: 'Campton',
                ),
              ),
              const SizedBox(height: 32),

              // Reasons List
              Expanded(
                child: ListView.builder(
                  itemCount: reasons.length,
                  itemBuilder: (context, index) {
                    return _buildReasonRow(reasons[index]);
                  },
                ),
              ),

                    // Action Button
                    _buildDeleteButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonRow(String reason) {
    final bool isSelected = selectedReason == reason;
    
    return GestureDetector(
      onTap: () => setState(() => selectedReason = reason),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Custom Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFF777F84),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFDAF40) : Colors.transparent,
              ),
              child: isSelected 
                ? const Icon(Icons.check, size: 16, color: Colors.white) 
                : null,
            ),
            const SizedBox(width: 12),
            // Reason Text
            Text(
              reason,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E2021),
                fontFamily: 'Campton',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final isDisabled = selectedReason == null || _isDeleting;
    
    return InkWell(
      onTap: isDisabled ? null : () {
        ConfirmationModal.show(
          context,
          title: 'Delete Shop',
          message: 'Are you sure you want to delete your shop? This action cannot be undone.',
          confirmLabel: 'Delete',
          onConfirm: _deleteShop,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: isDisabled 
              ? const Color(0xFFFDAF40).withOpacity(0.5) 
              : const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDisabled ? null : [
            BoxShadow(
              color: const Color(0xFFFDAF40).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: _isDeleting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFFFBF5)),
                  ),
                )
              : const Text(
                  "Continue to delete",
                  style: TextStyle(
                    color: Color(0xFFFFFBF5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                  ),
                ),
        ),
      ),
    );
  }
}