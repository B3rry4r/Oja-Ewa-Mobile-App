import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import '../domain/seller_profile_payload.dart';
import 'controllers/seller_profile_controller.dart';
import 'draft_utils.dart';
import 'seller_registration_draft.dart';

class AccountReviewScreen extends ConsumerWidget {
  const AccountReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final draft = sellerDraftFromArgs(args);
    final state = ref.watch(sellerProfileControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // Background from IR
      body: Column(
        children: [
          const AppHeader(
            backgroundColor: Color(0xFFFFF8F1),
            iconColor: Color(0xFF241508),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildStepper(), // Row-based stepper showing all steps complete

                  const Spacer(flex: 2),

                  // Success/Review Illustration Placeholder
                  const Icon(
                    Icons.access_time_filled_rounded,
                    size: 80,
                    color: Color(0xFFFDAF40),
                  ),

                  const SizedBox(height: 32),

                  // Status Message
                  const Text(
                    "We are reviewing your application\nThis takes 12-24 hours.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // --- Primary Action Button ---
                  _buildGoHomeButton(context, ref, draft, state.isLoading),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Row-based Stepper with all items highlighted
  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepItem(1, "Basic\nInfo", isComplete: true),
        _stepItem(2, "Business\nDetails", isComplete: true),
        _stepItem(3, "Account\non review", isComplete: true),
      ],
    );
  }

  Widget _stepItem(int num, String label, {required bool isComplete}) {
    final Color activeColor = const Color(0xFF603814);
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: (num < 3) 
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                num.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            height: 1.2,
            color: activeColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGoHomeButton(BuildContext context, WidgetRef ref, SellerRegistrationDraft draft, bool isLoading) {
    return InkWell(
      onTap: isLoading
          ? null
          : () async {
              final payload = SellerProfilePayload(
                country: draft.country ?? '',
                state: draft.state ?? '',
                city: draft.city ?? '',
                address: draft.address ?? '',
                businessEmail: draft.businessEmail ?? '',
                businessPhoneNumber: draft.businessPhoneNumber ?? '',
                instagram: draft.instagram,
                facebook: draft.facebook,
                identityDocument: draft.identityDocumentPath,
                businessName: draft.businessName ?? '',
                businessRegistrationNumber: draft.businessRegistrationNumber ?? '',
                businessCertificate: draft.businessCertificatePath,
                businessLogo: draft.businessLogoPath,
                bankName: draft.bankName ?? '',
                accountNumber: draft.accountNumber ?? '',
              );

              try {
                await ref.read(sellerProfileControllerProvider.notifier).submit(payload);
                if (!context.mounted) return;
                AppSnackbars.showSuccess(context, 'Seller application submitted');
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
              } catch (e) {
                if (!context.mounted) return;
                AppSnackbars.showError(context, UiErrorMessage.from(e));
              }
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: const Center(
          child: Text(
            "Go Home",
            style: TextStyle(
              color: Color(0xFFFFFBF5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}