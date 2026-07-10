import 'package:flutter/material.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/features/account/subfeatures/shared/widgets/compliance_progress_banner.dart';

/// Step 3 for the "Show your business" flow.
///
/// IMPORTANT: This is intentionally separate from the Start Selling flow's
/// `AccountReviewScreen` so we don't change its navigation behavior.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

import '../domain/business_profile_payload.dart';
import 'controllers/business_profile_controller.dart';
import '../data/business_profile_repository_impl.dart';
import 'package:ojaewa/core/files/multipart_utils.dart';
import 'selected_category_forms/draft_utils.dart';
import 'selected_category_forms/business_registration_draft.dart';

class BusinessAccountReviewScreen extends ConsumerStatefulWidget {
  const BusinessAccountReviewScreen({super.key});

  @override
  ConsumerState<BusinessAccountReviewScreen> createState() =>
      _BusinessAccountReviewScreenState();
}

class _BusinessAccountReviewScreenState
    extends ConsumerState<BusinessAccountReviewScreen> {
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final args = ModalRoute.of(context)?.settings.arguments;
    final draft = draftFromArgs(args, categoryLabelFallback: 'Beauty');

    // Same fix as the seller flow's account_review: AppPageScaffold defaults to
    // scrollable: false, so this step could not scroll and the submit button was
    // unreachable on shorter devices. The Spacers below centre the content when
    // there is room, so ConstrainedBox(minHeight) + IntrinsicHeight are used to
    // give the Column a bounded height instead of a bare SingleChildScrollView,
    // which would throw on the unbounded flex.
    return AppPageScaffold(
      showBack: !_isSubmitted,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const ComplianceProgressBanner(
                    title: 'Business compliance review',
                    subtitle:
                        'Review the submitted business sections before the final compliance submission.',
                    currentSection: 'Signature',
                    sectionLabels: [
                      'Business Information',
                      'Business Type & Industry',
                      'Registered Office',
                      'Authorized Signatory',
                      'Beneficial Owners',
                      'Banking & Settlement',
                      'Declarations',
                      'Signature',
                    ],
                  ),
                  const Spacer(flex: 2),
                  Icon(
                    _isSubmitted
                        ? Icons.check_circle
                        : Icons.access_time_filled_rounded,
                    size: 80,
                    color: colors.accent,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isSubmitted
                        ? 'Your business has been submitted!\nWe will review it within 12-24 hours.'
                        : 'Ready to submit your business profile?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 3),
                  _isSubmitted
                      ? _buildDoneButton(context)
                      : _buildSubmitButton(context, draft),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    BusinessRegistrationDraft draft,
  ) {
    final colors = context.appColors;
    return InkWell(
      onTap: _isSubmitting ? null : () => _submitForReview(context, draft),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: _isSubmitting ? colors.accent.withAlpha(150) : colors.accent,
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
                  'Submit for Review',
                  style: TextStyle(
                    color: colors.onAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
              color: colors.shadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Done',
            style: TextStyle(
              color: colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForReview(
    BuildContext context,
    BusinessRegistrationDraft draft,
  ) async {
    setState(() => _isSubmitting = true);

    // Map draft -> API payload
    // Clean + validate lists before submission
    final cleanedProductList = (draft.productList ?? const [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final cleanedServiceList = (draft.serviceList ?? const [])
        .where((s) => s.name.trim().isNotEmpty)
        .toList();
    final cleanedClasses = (draft.classesOffered ?? const [])
        .where((c) => c.name.trim().isNotEmpty)
        .toList();

    // Validation rules
    final offering = draft.offeringType;
    if (offering == 'providing_service') {
      if ((draft.professionalTitle ?? '').trim().isEmpty) {
        setState(() => _isSubmitting = false);
        AppSnackbars.showError(
          context,
          UiErrorMessage.from('Professional title is required'),
        );
        return;
      }
      if (cleanedServiceList.isEmpty) {
        setState(() => _isSubmitting = false);
        AppSnackbars.showError(
          context,
          UiErrorMessage.from('Please add at least one service'),
        );
        return;
      }
    }

    if (mapCategoryLabelToEnum(draft.categoryLabel) == 'school') {
      if ((draft.schoolBiography ?? '').trim().isEmpty) {
        setState(() => _isSubmitting = false);
        AppSnackbars.showError(
          context,
          UiErrorMessage.from('School biography is required'),
        );
        return;
      }
      if (cleanedClasses.isEmpty) {
        setState(() => _isSubmitting = false);
        AppSnackbars.showError(
          context,
          UiErrorMessage.from('Please add at least one class'),
        );
        return;
      }
    }

    if (draft.categoryId == null || draft.subcategoryId == null) {
      setState(() => _isSubmitting = false);
      AppSnackbars.showError(
        context,
        UiErrorMessage.from('Please select a category'),
      );
      return;
    }

    final payload = BusinessProfilePayload(
      category: mapCategoryLabelToEnum(draft.categoryLabel),
      categoryId: draft.categoryId!,
      subcategoryId: draft.subcategoryId!,
      businessName: (draft.businessName ?? '').trim(),
      legalBusinessName: (draft.legalBusinessName ?? '').trim(),
      tradingName: (draft.tradingName ?? '').trim(),
      businessDescription: (draft.businessDescription ?? '').trim(),
      website: draft.website,
      businessEmail: (draft.businessEmail ?? '').trim(),
      businessPhoneNumber: (draft.businessPhoneNumber ?? '').trim(),
      businessRegistrationNumber: (draft.businessRegistrationNumber ?? '')
          .trim(),
      taxIdentificationNumber: (draft.taxIdentificationNumber ?? '').trim(),
      nin: (draft.nin ?? '').trim().isEmpty ? null : (draft.nin ?? '').trim(),
      bvn: (draft.bvn ?? '').trim().isEmpty ? null : (draft.bvn ?? '').trim(),
      dateOfIncorporation: (draft.dateOfIncorporation ?? '').trim(),
      countryOfIncorporation: (draft.countryOfIncorporation ?? '').trim(),
      industrySector: (draft.industrySector ?? '').trim(),
      businessType: (draft.businessType ?? '').trim(),
      otherBusinessType: (draft.otherBusinessType ?? '').trim(),
      numberOfEmployees: draft.numberOfEmployees ?? 0,
      annualTurnoverRange: (draft.annualTurnoverRange ?? '').trim(),
      address: (draft.address ?? '').trim(),
      city: (draft.city ?? '').trim(),
      state: (draft.state ?? '').trim(),
      postalCode: (draft.postalCode ?? '').trim(),
      country: (draft.country ?? '').trim(),
      authorizedSignatoryFullName: (draft.authorizedSignatoryFullName ?? '')
          .trim(),
      authorizedSignatoryJobTitle: (draft.authorizedSignatoryJobTitle ?? '')
          .trim(),
      authorizedSignatoryEmail: (draft.authorizedSignatoryEmail ?? '').trim(),
      authorizedSignatoryPhoneNumber:
          (draft.authorizedSignatoryPhoneNumber ?? '').trim(),
      authorizedSignatoryIdNumber:
          (draft.authorizedSignatoryIdNumber ?? '').trim().isNotEmpty
          ? (draft.authorizedSignatoryIdNumber ?? '').trim()
          : _derivedIdentityNumber(draft),
      authorizedSignatoryDateOfBirth:
          (draft.authorizedSignatoryDateOfBirth ?? '').trim(),
      beneficialOwners: draft.beneficialOwners ?? const [],
      preferredSettlementCurrency: (draft.preferredSettlementCurrency ?? 'NGN')
          .trim(),
      declarationLegalRegistered: draft.declarationLegalRegistered ?? false,
      declarationInformationTrue: draft.declarationInformationTrue ?? false,
      declarationAuthorizeVerification:
          draft.declarationAuthorizeVerification ?? false,
      authorizeSettlementAccount: draft.authorizeSettlementAccount ?? false,
      acceptPartnerBankTerms: draft.acceptPartnerBankTerms ?? false,
      printedNameOfAuthorizedSignatory:
          (draft.printedNameOfAuthorizedSignatory ?? '').trim(),
      authorizedSignatorySignature: draft.authorizedSignatorySignaturePath,
      submissionDate: (draft.submissionDate ?? '').trim(),
      identityDocument: draft.identityDocumentPath,
      offeringType: draft.offeringType,
      productList: cleanedProductList,
      serviceList: cleanedServiceList,
      businessCertificates: draft.businessCertificates,
      professionalTitle: (draft.professionalTitle ?? '').trim(),
      schoolType: draft.schoolType,
      schoolBiography: (draft.schoolBiography ?? '').trim(),
      classesOffered: cleanedClasses,
      musicCategory: draft.musicCategory,
      youtube: draft.youtube,
      spotify: draft.spotify,
    );

    try {
      final res = await ref
          .read(businessProfileControllerProvider.notifier)
          .submit(payload);

      // Extract business id if present
      final data = res['data'];
      final businessId = (data is Map<String, dynamic>) ? data['id'] : null;
      if (businessId is int) {
        final api = ref.read(businessProfileApiProvider);

        if ((draft.identityDocumentPath ?? '').isNotEmpty) {
          await api.uploadFile(
            businessId: businessId,
            fileType: 'identity_document',
            file: await multipartFromPathCompressed(draft.identityDocumentPath!),
          );
        }

        if ((draft.businessLogoPath ?? '').isNotEmpty) {
          await api.uploadFile(
            businessId: businessId,
            fileType: 'business_logo',
            file: await multipartFromPathCompressed(draft.businessLogoPath!),
          );
        }

        // business_certificates file_type expects a single file per call per docs
        if ((draft.businessCertificates ?? []).isNotEmpty) {
          final first = draft.businessCertificates!.first;
          final path = first['path'];
          if (path is String && path.isNotEmpty) {
            await api.uploadFile(
              businessId: businessId,
              fileType: 'business_certificates',
              file: await multipartFromPathCompressed(path),
            );
          }
        }

        // Upload the drawn signature image. Previously only its local device
        // path was sent to create() as a string and never uploaded, so the DB
        // held a useless on-device path. Mirror the seller flow: overwrite the
        // column with the real hosted file URL.
        if ((draft.authorizedSignatorySignaturePath ?? '').isNotEmpty) {
          await api.uploadFile(
            businessId: businessId,
            fileType: 'authorized_signatory_signature',
            file: await multipartFromPathCompressed(
                draft.authorizedSignatorySignaturePath!),
          );
        }
      }

      if (!context.mounted) return;
      AppSnackbars.showSuccess(context, 'Business submitted for review');
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbars.showError(context, UiErrorMessage.from(e));
    }
  }

  String _derivedIdentityNumber(BusinessRegistrationDraft draft) {
    final nin = (draft.nin ?? '').trim();
    if (nin.isNotEmpty) return 'NIN:$nin';
    final bvn = (draft.bvn ?? '').trim();
    if (bvn.isNotEmpty) return 'BVN:$bvn';
    return '';
  }
}
