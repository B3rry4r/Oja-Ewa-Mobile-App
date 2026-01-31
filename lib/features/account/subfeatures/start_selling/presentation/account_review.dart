import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

import '../../../../../app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import '../domain/seller_profile_payload.dart';
import 'controllers/seller_profile_controller.dart';
import '../data/seller_profile_upload_repository_impl.dart';
import 'package:ojaewa/core/files/multipart_utils.dart';
import 'draft_utils.dart';
import 'seller_registration_draft.dart';

class AccountReviewScreen extends ConsumerStatefulWidget {
  const AccountReviewScreen({super.key});

  @override
  ConsumerState<AccountReviewScreen> createState() =>
      _AccountReviewScreenState();
}

class _AccountReviewScreenState extends ConsumerState<AccountReviewScreen> {
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final args = ModalRoute.of(context)?.settings.arguments;
    final draft = sellerDraftFromArgs(args);

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
                  Text(
                    _isSubmitted
                        ? "Your seller application has been submitted\nThis takes 12-24 hours."
                        : "Ready to submit your seller application?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Quality Standards Section (only show before submission)
                  if (!_isSubmitted) ...[
                    _buildQualityStandards(),
                    const SizedBox(height: 24),
                  ],

                  // --- Primary Action Button ---
                  _isSubmitted
                      ? _buildDoneButton(context)
                      : _buildSubmitButton(context, draft),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildGoHomeButton(
    BuildContext context,
    WidgetRef ref,
    SellerRegistrationDraft draft,
    bool isLoading,
  ) {
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
                businessRegistrationNumber:
                    draft.businessRegistrationNumber ?? '',
                businessCertificate: draft.businessCertificatePath,
                businessLogo: draft.businessLogoPath,
                bankName: draft.bankName ?? '',
                accountNumber: draft.accountNumber ?? '',
              );

              try {
                // 1) Create profile
                await ref
                    .read(sellerProfileControllerProvider.notifier)
                    .submit(payload);

                // 2) Upload files (best effort; these endpoints also update profile fields)
                final uploadRepo = ref.read(
                  sellerProfileUploadRepositoryProvider,
                );
                if ((draft.identityDocumentPath ?? '').isNotEmpty) {
                  await uploadRepo.upload(
                    type: 'identity_document',
                    file: multipartFromPath(draft.identityDocumentPath!),
                  );
                }

                if ((draft.businessCertificatePath ?? '').isNotEmpty) {
                  await uploadRepo.upload(
                    type: 'business_certificate',
                    file: multipartFromPath(draft.businessCertificatePath!),
                  );
                }

                if ((draft.businessLogoPath ?? '').isNotEmpty) {
                  await uploadRepo.upload(
                    type: 'business_logo',
                    file: multipartFromPath(draft.businessLogoPath!),
                  );
                }

                if (!context.mounted) return;
                AppSnackbars.showSuccess(
                  context,
                  'Seller application submitted',
                );
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
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
              color: const Color(0xFFFDAF40).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
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

  Widget _buildQualityStandards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDAF40), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAF40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Color(0xFFFDAF40),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Our Quality Promise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: Color(0xFF241508),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'At Ojá-Ẹwà your trust is our foundation. Every product on Ojá-Ẹwà must pass our verification for authenticity and craftsmanship.\n\n'
            'We guarantee: If a newly registered brand/product fails our review and does not meet our published Quality Standards, its registration fee will be fully refunded.\n\n'
            'We invest in your success by ensuring only excellence reaches our marketplace.\n\n'
            'Based on who you be, we ensure what you sell is worthy.\n\n'
            'The Ojá-Ẹwà Team',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: Color(0xFF1E2021),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    SellerRegistrationDraft draft,
  ) {
    return InkWell(
      onTap: _isSubmitting ? null : () => _submitSeller(context, draft),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: _isSubmitting
              ? const Color(0xFFFDAF40).withAlpha(150)
              : const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withAlpha(102),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFFBF5),
                    ),
                  ),
                )
              : const Text(
                  "Submit for Review",
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

  Widget _buildDoneButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: const Color(0xFFFDAF40),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFDAF40).withAlpha(102),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Done",
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

  Future<void> _submitSeller(
    BuildContext context,
    SellerRegistrationDraft draft,
  ) async {
    setState(() => _isSubmitting = true);

    final payload = SellerProfilePayload(
      country: (draft.country ?? '').trim(),
      state: (draft.state ?? '').trim(),
      city: (draft.city ?? '').trim(),
      address: (draft.address ?? '').trim(),
      businessEmail: (draft.businessEmail ?? '').trim(),
      businessPhoneNumber: (draft.businessPhoneNumber ?? '').trim(),
      instagram: draft.instagram,
      facebook: draft.facebook,
      identityDocument: draft.identityDocumentPath,
      businessName: (draft.businessName ?? '').trim(),
      businessRegistrationNumber: (draft.businessRegistrationNumber ?? '')
          .trim(),
      businessCertificate: draft.businessCertificatePath,
      businessLogo: draft.businessLogoPath,
      bankName: (draft.bankName ?? '').trim(),
      accountNumber: (draft.accountNumber ?? '').trim(),
    );

    try {
      await ref.read(sellerProfileControllerProvider.notifier).submit(payload);

      final uploadRepo = ref.read(sellerProfileUploadRepositoryProvider);
      if ((draft.identityDocumentPath ?? '').isNotEmpty) {
        await uploadRepo.upload(
          type: 'identity_document',
          file: multipartFromPath(draft.identityDocumentPath!),
        );
      }

      if ((draft.businessCertificatePath ?? '').isNotEmpty) {
        await uploadRepo.upload(
          type: 'business_certificate',
          file: multipartFromPath(draft.businessCertificatePath!),
        );
      }

      if ((draft.businessLogoPath ?? '').isNotEmpty) {
        await uploadRepo.upload(
          type: 'business_logo',
          file: multipartFromPath(draft.businessLogoPath!),
        );
      }

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Seller application submitted');
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbars.showError(context, UiErrorMessage.from(e));
    }
  }
}
