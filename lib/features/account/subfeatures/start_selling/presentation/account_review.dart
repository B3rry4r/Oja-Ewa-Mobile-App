import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

import '../../../../../app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import '../domain/seller_profile_payload.dart';
import 'controllers/seller_profile_controller.dart';
import 'controllers/seller_status_controller.dart';
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

  bool _isLocalFilePath(String? path) =>
      path != null && path.isNotEmpty && !path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final args = ModalRoute.of(context)?.settings.arguments;
    final draft = sellerDraftFromArgs(args);

    return AppPageScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildStepper(),
            const Spacer(flex: 2),
            Icon(
              Icons.access_time_filled_rounded,
              size: 80,
              color: colors.accent,
            ),
            const SizedBox(height: 32),
            Text(
              _isSubmitted
                  ? "Your seller application has been submitted\nThis takes 12-24 hours."
                  : "Ready to submit your seller application?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
            if (!_isSubmitted) ...[
              _buildQualityStandards(),
              const SizedBox(height: 24),
            ],
            _isSubmitted
                ? _buildDoneButton(context)
                : _buildSubmitButton(draft),
            const SizedBox(height: 40),
          ],
        ),
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
    final colors = context.appColors;
    final Color activeColor = colors.textPrimary;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: (num < 3)
              ? Icon(Icons.check, color: colors.background, size: 16)
              : Text(
                  num.toString(),
                  style: TextStyle(
                    color: colors.background,
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

  Widget _buildQualityStandards() {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: colors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Our Quality Promise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Campton',
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'At Ojá-Ẹwà your trust is our foundation. Every product on Ojá-Ẹwà must pass our verification for authenticity and craftsmanship.\n\n'
            'We guarantee: If a newly registered brand/product fails our review and does not meet our published Quality Standards, its registration fee will be fully refunded.\n\n'
            'We invest in your success by ensuring only excellence reaches our marketplace.\n\n'
            'Based on who you be, we ensure what you sell is worthy.\n\n'
            'The Ojá-Ẹwà Team',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(SellerRegistrationDraft draft) {
    final colors = context.appColors;
    return InkWell(
      onTap: _isSubmitting ? null : () => _submitSeller(draft),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: _isSubmitting
              ? colors.accent.withValues(alpha: 0.6)
              : colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.onAccent),
                  ),
                )
              : Text(
                  "Submit for Review",
                  style: TextStyle(
                    color: colors.onAccent,
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
    final colors = context.appColors;
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Done",
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Campton',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitSeller(SellerRegistrationDraft draft) async {
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
      final res = await ref
          .read(sellerProfileControllerProvider.notifier)
          .submit(payload, isUpdate: draft.isResubmission);

      final uploadRepo = ref.read(sellerProfileUploadRepositoryProvider);
      if (_isLocalFilePath(draft.identityDocumentPath)) {
        await uploadRepo.upload(
          type: 'identity_document',
          file: multipartFromPath(draft.identityDocumentPath!),
        );
      }

      if (_isLocalFilePath(draft.businessCertificatePath)) {
        await uploadRepo.upload(
          type: 'business_certificate',
          file: multipartFromPath(draft.businessCertificatePath!),
        );
      }

      if (_isLocalFilePath(draft.businessLogoPath)) {
        await uploadRepo.upload(
          type: 'business_logo',
          file: multipartFromPath(draft.businessLogoPath!),
        );
      }

      ref.invalidate(mySellerStatusProvider);

      if (!mounted) return;
      final pendingAfterSubmit =
          (res['registration_status'] as String?) == 'pending';
      AppSnackbars.showSuccess(
        context,
        draft.isResubmission && pendingAfterSubmit
            ? 'Seller profile resubmitted for review'
            : 'Seller application submitted',
      );
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
