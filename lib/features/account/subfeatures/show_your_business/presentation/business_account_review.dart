import 'package:flutter/material.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';

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

class BusinessAccountReviewScreen extends ConsumerWidget {
  const BusinessAccountReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final args = ModalRoute.of(context)?.settings.arguments;
    final draft = draftFromArgs(args, categoryLabelFallback: 'Beauty');

    final state = ref.watch(businessProfileControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
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
                  _buildStepper(),
                  const Spacer(flex: 2),
                  const Icon(
                    Icons.access_time_filled_rounded,
                    size: 80,
                    color: Color(0xFFFDAF40),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'We are reviewing your application\nThis takes 12-24 hours.',
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
                  _buildContinueButton(context, ref, draft, state.isLoading),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stepItem(1, 'Basic\nInfo', isComplete: true),
        _stepItem(2, 'Business\nDetails', isComplete: true),
        _stepItem(3, 'Account\non review', isComplete: true),
      ],
    );
  }

  static Widget _stepItem(int num, String label, {required bool isComplete}) {
    final activeColor = const Color(0xFF603814);

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

  Widget _buildContinueButton(
    BuildContext context,
    WidgetRef ref,
    BusinessRegistrationDraft draft,
    bool isLoading,
  ) {
    return InkWell(
      onTap: isLoading
          ? null
          : () async {
              // Map draft -> API payload
              final payload = BusinessProfilePayload(
                category: mapCategoryLabelToEnum(draft.categoryLabel),
                country: draft.country ?? '',
                state: draft.state ?? '',
                city: draft.city ?? '',
                address: draft.address ?? '',
                businessEmail: draft.businessEmail ?? '',
                businessPhoneNumber: draft.businessPhoneNumber ?? '',
                websiteUrl: draft.websiteUrl,
                instagram: draft.instagram,
                facebook: draft.facebook,
                identityDocument: draft.identityDocumentPath,
                businessName: draft.businessName ?? '',
                businessDescription: draft.businessDescription ?? '',
                offeringType: draft.offeringType,
                productList: parseProductListText(draft.productListText),
                serviceList: draft.serviceList,
                businessCertificates: draft.businessCertificates,
                professionalTitle: draft.professionalTitle,
                schoolType: draft.schoolType,
                schoolBiography: draft.schoolBiography,
                classesOffered: draft.classesOffered,
                musicCategory: draft.musicCategory,
                youtube: draft.youtube,
                spotify: draft.spotify,
              );

              try {
                final res = await ref.read(businessProfileControllerProvider.notifier).submit(payload);

                // Extract business id if present
                final data = res['data'];
                final businessId = (data is Map<String, dynamic>) ? data['id'] : null;
                if (businessId is int) {
                  final api = ref.read(businessProfileApiProvider);

                  if ((draft.identityDocumentPath ?? '').isNotEmpty) {
                    await api.uploadFile(
                      businessId: businessId,
                      fileType: 'identity_document',
                      file: multipartFromPath(draft.identityDocumentPath!),
                    );
                  }

                  if ((draft.businessLogoPath ?? '').isNotEmpty) {
                    await api.uploadFile(
                      businessId: businessId,
                      fileType: 'business_logo',
                      file: multipartFromPath(draft.businessLogoPath!),
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
                        file: multipartFromPath(path),
                      );
                    }
                  }
                }

                if (!context.mounted) return;
                AppSnackbars.showSuccess(context, 'Business submitted for review');
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
            'Continue',
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
