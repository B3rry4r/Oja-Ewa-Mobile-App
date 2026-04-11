import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/app_services/presentation/screens/app_service_ui.dart';

import '../data/badge_verifications_api.dart';
import 'controllers/badge_verifications_controller.dart';

class BadgeVerificationsScreen extends ConsumerStatefulWidget {
  const BadgeVerificationsScreen({super.key});

  @override
  ConsumerState<BadgeVerificationsScreen> createState() =>
      _BadgeVerificationsScreenState();
}

class _BadgeVerificationsScreenState
    extends ConsumerState<BadgeVerificationsScreen> {
  final _sellerProfileIdController = TextEditingController();
  final _businessProfileUrlController = TextEditingController();
  final _validIdUrlController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedBadge;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _sellerProfileIdController.dispose();
    _businessProfileUrlController.dispose();
    _validIdUrlController.dispose();
    _yearsExperienceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(badgeOptionsProvider);
    final requestsAsync = ref.watch(badgeVerificationRequestsProvider);
    final colors = context.appColors;

    return AppPageScaffold(
      title: 'Verification Badges',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceIntroCard(
            title: 'Apply for a verification badge',
            description:
                'Choose the badge you want, attach the required details, and then continue to payment and submission.',
            badge: 'Badges',
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Available badges',
            actionLabel: 'Refresh',
            onAction: () {
              ref.invalidate(badgeOptionsProvider);
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
                                Text(
                                  'NGN ${option.priceNgn}',
                                  style: TextStyle(
                                    color: colors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              option.name,
                              style: TextStyle(color: colors.textSecondary),
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
                  controller: _sellerProfileIdController,
                  label: 'Seller profile ID',
                  hint: '14',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _businessProfileUrlController,
                  label: 'Business profile URL',
                  hint: 'https://example.com/profile.pdf',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _validIdUrlController,
                  label: 'Valid ID URL',
                  hint: 'https://example.com/id.jpg',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _yearsExperienceController,
                  label: 'Years of experience',
                  hint: '7',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Traditional weaving specialist',
                  minLines: 3,
                  maxLines: 4,
                ),
              ],
            ),
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
                  : const Text('Pay & Submit Badge Request'),
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'My requests',
            actionLabel: 'Refresh',
            onAction: () {
              ref.invalidate(badgeVerificationRequestsProvider);
            },
          ),
          const SizedBox(height: 12),
          requestsAsync.when(
            loading: () => const ServiceListSkeleton(),
            error: (error, stackTrace) => ServiceErrorState(
              message: 'Unable to load badge requests',
              onRetry: () {
                ref.invalidate(badgeVerificationRequestsProvider);
              },
            ),
            data: (items) {
              if (items.isEmpty) {
                return const ServiceEmptyState(
                  title: 'No badge verification requests yet',
                  description:
                      'Submitted badge applications will appear here with their review status.',
                );
              }
              return Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StatusCard(
                        title: item.badge,
                        status: item.status,
                        reference: item.applicationReference,
                        trailing: item.amount == null
                            ? null
                            : '${item.currency ?? 'NGN'} ${item.amount}',
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final selectedBadge = _selectedBadge;
    if (selectedBadge == null ||
        _sellerProfileIdController.text.trim().isEmpty ||
        _businessProfileUrlController.text.trim().isEmpty ||
        _validIdUrlController.text.trim().isEmpty) {
      AppSnackbars.showError(
        context,
        'Fill all badge application fields first',
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
      final purchase = await ref
          .read(iapServiceProvider)
          .purchaseService(productId);
      if (purchase == null) {
        if (mounted) {
          AppSnackbars.showError(context, 'Payment was not completed');
        }
        return;
      }

      await ref
          .read(badgeVerificationsApiProvider)
          .createRequest(
            badge: selectedBadge,
            sellerProfileId:
                int.tryParse(_sellerProfileIdController.text.trim()) ?? 0,
            documents: {
              'business_profile_url': _businessProfileUrlController.text.trim(),
              'valid_id_url': _validIdUrlController.text.trim(),
            },
            answers: {
              if (_yearsExperienceController.text.trim().isNotEmpty)
                'years_experience':
                    int.tryParse(_yearsExperienceController.text.trim()) ?? 0,
              if (_notesController.text.trim().isNotEmpty)
                'notes': _notesController.text.trim(),
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

class _ServiceField extends StatelessWidget {
  const _ServiceField({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int maxLines;

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
