import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/constants/app_urls.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/app_services/presentation/screens/app_service_ui.dart';

import '../data/badge_verifications_api.dart';
import '../domain/badge_option.dart';
import '../domain/badge_verification_request.dart';
import 'controllers/badge_verifications_controller.dart';

class BadgeVerificationsScreen extends ConsumerStatefulWidget {
  const BadgeVerificationsScreen({super.key});

  @override
  ConsumerState<BadgeVerificationsScreen> createState() =>
      _BadgeVerificationsScreenState();
}

class _BadgeVerificationsScreenState
    extends ConsumerState<BadgeVerificationsScreen> {
  final _yearsExperienceController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedBadge;
  bool _isSubmitting = false;
  bool _isUploadingDocument = false;
  final List<String> _supportingDocumentUrls = [];

  @override
  void dispose() {
    _yearsExperienceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(badgeOptionsProvider);
    final requestsAsync = ref.watch(badgeVerificationRequestsProvider);
    final sellerStatusAsync = ref.watch(mySellerStatusProvider);

    return AppPageScaffold(
      title: 'Verification Badges',
      scrollable: true,
      child: sellerStatusAsync.when(
        loading: () => const ServiceListSkeleton(),
        error: (error, stackTrace) => const ServiceEmptyState(
          title: 'Seller profile unavailable',
          description:
              'We could not load your seller profile right now. Try again before applying for a badge.',
        ),
        data: (seller) {
          if (seller == null || seller.id == null) {
            return const ServiceEmptyState(
              title: 'Create your seller profile first',
              description:
                  'Finish your seller profile first, then come back here to apply for a badge.',
            );
          }

          final hasIdentityDocument = (seller.identityDocument ?? '')
              .trim()
              .isNotEmpty;
          final hasBusinessDocument =
              (seller.businessCertificate ?? '').trim().isNotEmpty ||
              (seller.businessLogo ?? '').trim().isNotEmpty;
          final sellerName =
              (seller.legalBusinessName ?? seller.businessName ?? '').trim();

          return requestsAsync.when(
            loading: () => const ServiceListSkeleton(),
            error: (error, stackTrace) => ServiceErrorState(
              message: 'Unable to load badge requests',
              onRetry: () {
                ref.invalidate(badgeVerificationRequestsProvider);
              },
            ),
            data: (items) {
              BadgeVerificationRequest? activeRequest;
              for (final item in items) {
                if (_isActiveRequest(item.status)) {
                  activeRequest = item;
                  break;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activeRequest != null
                    ? _buildActiveRequestState(
                        sellerName: sellerName.isEmpty
                            ? 'Seller profile'
                            : sellerName,
                        currentBadge: seller.badge,
                        request: activeRequest,
                      )
                    : _buildApplyState(
                        sellerName: sellerName.isEmpty
                            ? 'Seller profile'
                            : sellerName,
                        currentBadge: seller.badge,
                        hasIdentityDocument: hasIdentityDocument,
                        hasBusinessDocument: hasBusinessDocument,
                        optionsAsync: optionsAsync,
                      ),
              );
            },
          );
        },
      ),
    );
  }

  bool _isActiveRequest(String status) {
    return status == 'submitted' ||
        status == 'under_review' ||
        status == 'info_required';
  }

  List<Widget> _buildActiveRequestState({
    required String sellerName,
    required String? currentBadge,
    required BadgeVerificationRequest request,
  }) {
    return [
      const ServiceIntroCard(
        title: 'Badge review in progress',
        description:
            'Your current badge application is already being processed. Track the review status here instead of submitting another one.',
        badge: 'Badges',
      ),
      const SizedBox(height: 20),
      _ProfileSourceCard(
        sellerName: sellerName,
        badge: currentBadge,
        hasIdentityDocument: true,
        hasBusinessDocument: true,
      ),
      const SizedBox(height: 16),
      SectionTitle(
        title: 'Application status',
        actionLabel: 'Refresh',
        onAction: () {
          ref.invalidate(badgeVerificationRequestsProvider);
          ref.invalidate(mySellerStatusProvider);
        },
      ),
      const SizedBox(height: 12),
      StatusCard(
        title: _badgeLabel(request.badge),
        subtitle: request.reviewNote,
        status: request.status,
        reference: request.applicationReference,
      ),
    ];
  }

  List<Widget> _buildApplyState({
    required String sellerName,
    required String? currentBadge,
    required bool hasIdentityDocument,
    required bool hasBusinessDocument,
    required AsyncValue<List<BadgeOption>> optionsAsync,
  }) {
    final colors = context.appColors;
    return [
      const ServiceIntroCard(
        title: 'Grow your seller badge',
        description:
            'Badges build trust on your seller profile and unlock stronger selling privileges. Choose the level you want and continue to payment.',
        badge: 'Badges',
      ),
      const SizedBox(height: 20),
      _ProfileSourceCard(
        sellerName: sellerName,
        badge: currentBadge,
        hasIdentityDocument: hasIdentityDocument,
        hasBusinessDocument: hasBusinessDocument,
      ),
      const SizedBox(height: 16),
      SectionTitle(
        title: 'Available badges',
        actionLabel: 'Refresh',
        onAction: () {
          ref.invalidate(badgeOptionsProvider);
          ref.invalidate(badgeVerificationRequestsProvider);
          ref.invalidate(mySellerStatusProvider);
        },
      ),
      const SizedBox(height: 12),
      optionsAsync.when(
        loading: () => const ServiceListSkeleton(),
        error: (error, stackTrace) => ServiceErrorState(
          message: 'Unable to load badge options',
          onRetry: () {
            ref.invalidate(badgeOptionsProvider);
          },
        ),
        data: (options) {
          if (options.isEmpty) {
            return const ServiceEmptyState(
              title: 'No badge options available',
              description: 'Badge options will appear here when available.',
            );
          }

          _selectedBadge ??= options.first.key;

          return Column(
            children: [
              for (final option in options)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBadge = option.key;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: option.key == _selectedBadge
                          ? colors.surfaceSecondary
                          : colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: option.key == _selectedBadge
                            ? colors.accent
                            : colors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (option.key == _selectedBadge)
                              Icon(
                                Icons.check_circle,
                                color: colors.accent,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          option.name,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _priceLabel(option),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (option.requirements.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          for (final requirement in option.requirements)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $requirement',
                                style: TextStyle(
                                  color: colors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      _FormCard(
        title: 'Application details',
        child: Column(
          children: [
            _ServiceField(
              controller: _yearsExperienceController,
              label: 'Years of experience',
              hint: '7',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _ServiceField(
              controller: _notesController,
              label: 'Nomination source or notes',
              hint: 'Guild recommendation, curator note, or other context',
              minLines: 3,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            _UploadCard(
              label: 'Supporting documents',
              helper: _supportingDocumentUrls.isEmpty
                  ? 'Optional. Upload supporting files if this badge needs more proof.'
                  : '${_supportingDocumentUrls.length} file(s) uploaded',
              uploaded: _supportingDocumentUrls.isNotEmpty,
              isLoading: _isUploadingDocument,
              onTap: _uploadSupportingDocument,
            ),
            const SizedBox(height: 12),
            Text(
              'Make sure your seller profile documents are complete before you apply for a badge.',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _SubscriptionTermsCard(
        onTerms: _openTerms,
        onPrivacy: _openPrivacy,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pay & Apply for Badge'),
        ),
      ),
    ];
  }

  Future<void> _submit() async {
    final selectedBadge = _selectedBadge;
    final seller = ref.read(mySellerStatusProvider).value;
    if (selectedBadge == null || seller == null || seller.id == null) {
      AppSnackbars.showError(
        context,
        'Create your seller profile before applying for a badge',
      );
      return;
    }

    final businessProfileUrl =
        (seller.businessCertificate ?? seller.businessLogo ?? '').trim();
    final validIdUrl = (seller.identityDocument ?? '').trim();
    if (businessProfileUrl.isEmpty || validIdUrl.isEmpty) {
      AppSnackbars.showError(
        context,
        'Update your seller profile documents before applying for a badge',
      );
      return;
    }

    final productId = ServiceProducts.badgeProductForKey(selectedBadge);
    if (productId == null) {
      AppSnackbars.showError(context, 'Unsupported badge product');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final iap = ref.read(iapServiceProvider);
      final purchase = await iap.purchaseService(productId);
      if (purchase == null) {
        if (mounted) {
          AppSnackbars.showError(
            context,
            iap.lastServiceError ?? 'Payment was not completed',
          );
        }
        return;
      }

      await ref
          .read(badgeVerificationsApiProvider)
          .createRequest(
            badge: selectedBadge,
            documents: _supportingDocumentUrls
                .map((url) => {'type': 'supporting_document', 'url': url})
                .toList(),
            answers: {
              if (_yearsExperienceController.text.trim().isNotEmpty)
                'experience_years': _yearsExperienceController.text.trim(),
              if (_notesController.text.trim().isNotEmpty)
                'nomination_source': _notesController.text.trim(),
            },
            purchase: purchase,
          );
      ref.invalidate(badgeVerificationRequestsProvider);
      if (mounted) AppSnackbars.showSuccess(context, 'Badge request submitted');
    } on DioException catch (e) {
      if (mounted) AppSnackbars.showError(context, _dioMessage(e));
    } catch (_) {
      if (mounted) {
        AppSnackbars.showError(context, 'Unable to submit badge request');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      final errors = data['errors'];
      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return 'Unable to submit badge request';
  }

  Future<void> _uploadSupportingDocument() async {
    final path = await pickSingleFilePath();
    if (path == null) return;
    setState(() => _isUploadingDocument = true);
    try {
      final upload = await ref
          .read(badgeVerificationsApiProvider)
          .uploadDocument(filePath: path, type: 'supporting_document');
      final url = upload['url'] as String?;
      if (url == null || url.isEmpty) {
        if (mounted) {
          setState(() => _isUploadingDocument = false);
          AppSnackbars.showError(context, 'Upload failed');
        }
        return;
      }
      if (!mounted) return;
      setState(() {
        _isUploadingDocument = false;
        _supportingDocumentUrls.add(url);
      });
      AppSnackbars.showSuccess(context, 'Supporting document uploaded');
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isUploadingDocument = false);
        AppSnackbars.showError(context, _dioMessage(e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isUploadingDocument = false);
        AppSnackbars.showError(context, 'Unable to upload supporting document');
      }
    }
  }

  String _badgeLabel(String key) {
    switch (key) {
      case 'certified_authentic':
        return 'White Badge';
      case 'heritage_artisan':
        return 'Gold Badge';
      case 'sustainable_innovator':
        return 'Green Badge';
      default:
        return key.replaceAll('_', ' ');
    }
  }

  /// Price + billing period shown on each badge so the purchase screen
  /// displays the subscription price and length (Apple Guideline 3.1.2(c)).
  String _priceLabel(BadgeOption option) {
    return '${_formatNgn(option.priceNgn)}${_billingCycleSuffix(option.billingCycle)}';
  }

  String _billingCycleSuffix(String billingCycle) {
    switch (billingCycle.toLowerCase()) {
      case 'yearly':
      case 'annual':
      case 'annually':
        return ' / year';
      case 'monthly':
      case 'month':
        return ' / month';
      case '':
        return '';
      default:
        return ' / ${billingCycle.toLowerCase()}';
    }
  }

  String _formatNgn(num amount) {
    final digits = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '₦$buffer';
  }

  void _openTerms() =>
      Navigator.of(context).pushNamed(AppRoutes.termsOfService);

  Future<void> _openPrivacy() async {
    await launchUrl(
      Uri.parse(AppUrls.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}

/// Auto-renewable subscription disclosure + functional Terms of Use (EULA)
/// and Privacy Policy links, shown on the purchase screen to satisfy Apple
/// Guideline 3.1.2(c).
class _SubscriptionTermsCard extends StatelessWidget {
  const _SubscriptionTermsCard({
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription details',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Badges are billed as an auto-renewing yearly subscription through '
            'your Apple ID. Payment is charged at confirmation of purchase and '
            'renews automatically for the same price and period unless you '
            'cancel at least 24 hours before the current period ends. You can '
            'manage or cancel anytime in your App Store account settings.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegalLink(label: 'Terms of Use (EULA)', onTap: onTerms),
              _LegalLink(label: 'Privacy Policy', onTap: onPrivacy),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: colors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.label,
    required this.helper,
    required this.uploaded,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final String helper;
  final bool uploaded;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: uploaded ? colors.accent : colors.border),
        ),
        child: isLoading
            ? const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF111111),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Uploading...', style: TextStyle(fontSize: 13)),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          helper,
                          style: TextStyle(
                            color: uploaded ? colors.accent : colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    uploaded ? Icons.check_circle : Icons.upload_file,
                    color: uploaded ? colors.accent : colors.textSecondary,
                  ),
                ],
              ),
      ),
    );
  }
}

class _ServiceField extends StatelessWidget {
  const _ServiceField({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textTertiary),
            filled: true,
            fillColor: colors.surfaceSecondary,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: colors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSourceCard extends StatelessWidget {
  const _ProfileSourceCard({
    required this.sellerName,
    required this.badge,
    required this.hasIdentityDocument,
    required this.hasBusinessDocument,
  });

  final String sellerName;
  final String? badge;
  final bool hasIdentityDocument;
  final bool hasBusinessDocument;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sellerName,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge == null || badge!.trim().isEmpty
                ? 'No badge active yet'
                : 'Current badge: ${badge!.replaceAll('_', ' ')}',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            hasIdentityDocument && hasBusinessDocument
                ? 'Your seller profile is ready for badge review. Choose the badge you want and continue to payment.'
                : 'Some required seller documents are still missing. Update your seller profile first, then return here to apply.',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
