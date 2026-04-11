import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/subscriptions/iap_service.dart';
import 'package:ojaewa/core/subscriptions/subscription_constants.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/app_services/presentation/screens/app_service_ui.dart';

import '../data/advert_placements_api.dart';
import 'controllers/advert_placements_controller.dart';

class AdvertPlacementsScreen extends ConsumerStatefulWidget {
  const AdvertPlacementsScreen({super.key});

  @override
  ConsumerState<AdvertPlacementsScreen> createState() =>
      _AdvertPlacementsScreenState();
}

class _AdvertPlacementsScreenState
    extends ConsumerState<AdvertPlacementsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  String _mediaType = 'image';
  String _displayCurrency = 'NGN';
  int _durationDays = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetUrlController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(advertPlacementRequestsProvider);
    final colors = context.appColors;

    return AppPageScaffold(
      title: 'Advert Placements',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceIntroCard(
            title: 'Create a new advert request',
            description:
                'Set your advert content, campaign dates, and destination link here before payment and submission.',
            badge: 'Adverts',
          ),
          const SizedBox(height: 20),
          _ServiceFormCard(
            title: 'Campaign details',
            child: Column(
              children: [
                _ServiceField(
                  controller: _titleController,
                  label: 'Advert title',
                  hint: 'My Promo',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Run this advert on the homepage banner',
                  minLines: 3,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ServiceDropdown(
                        label: 'Media type',
                        value: _mediaType,
                        items: const ['image', 'video'],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _mediaType = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_mediaType == 'image')
                  _ServiceField(
                    controller: _imageUrlController,
                    label: 'Image URL',
                    hint: 'https://example.com/banner.jpg',
                  )
                else ...[
                  _ServiceField(
                    controller: _videoUrlController,
                    label: 'Video URL',
                    hint: 'https://youtube.com/watch?v=test',
                  ),
                  const SizedBox(height: 12),
                  _ServiceField(
                    controller: _thumbnailUrlController,
                    label: 'Thumbnail URL',
                    hint: 'https://example.com/thumb.jpg',
                  ),
                ],
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _targetUrlController,
                  label: 'Target URL',
                  hint: 'https://example.com',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ServiceFormCard(
            title: 'Duration and pricing',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advert package',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [1, 3, 7, 14, 30]
                      .map(
                        (days) => _DurationOption(
                          days: days,
                          isSelected: _durationDays == days,
                          onTap: () {
                            setState(() {
                              _durationDays = days;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  'Placement is fixed to homepage banner. Start and end dates are generated automatically from the selected package after payment.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _ServiceDropdown(
                  label: 'Display currency',
                  value: _displayCurrency,
                  items: const ['NGN', 'USD'],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _displayCurrency = value);
                  },
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
                  : const Text('Pay & Submit Advert Request'),
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Placement history',
            actionLabel: 'Refresh',
            onAction: () {
              ref.invalidate(advertPlacementRequestsProvider);
            },
          ),
          const SizedBox(height: 12),
          requestsAsync.when(
            loading: () => const ServiceListSkeleton(),
            error: (error, stackTrace) => ServiceErrorState(
              message: 'Unable to load advert placement requests',
              onRetry: () {
                ref.invalidate(advertPlacementRequestsProvider);
              },
            ),
            data: (items) {
              if (items.isEmpty) {
                return const ServiceEmptyState(
                  title: 'No advert placement requests yet',
                  description:
                      'Submitted advert requests will appear here with review and scheduling status.',
                );
              }
              return Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StatusCard(
                        title: item.title,
                        subtitle: '${item.mediaType} · ${item.placement}',
                        status: item.status,
                        reference: item.applicationReference,
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
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _targetUrlController.text.trim().isEmpty ||
        (_mediaType == 'image' && _imageUrlController.text.trim().isEmpty) ||
        (_mediaType == 'video' && _videoUrlController.text.trim().isEmpty)) {
      AppSnackbars.showError(context, 'Fill all advert fields first');
      return;
    }

    final productId = ServiceProducts.advertProductForDuration(_durationDays);
    if (productId == null) {
      AppSnackbars.showError(
        context,
        'Supported advert packages are 1, 3, 7, 14, or 30 days',
      );
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
          .read(advertPlacementsApiProvider)
          .createRequest(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            placement: 'banner',
            mediaType: _mediaType,
            imageUrl: _mediaType == 'image'
                ? _imageUrlController.text.trim()
                : null,
            videoUrl: _mediaType == 'video'
                ? _videoUrlController.text.trim()
                : null,
            videoSource: _mediaType == 'video'
                ? _videoSourceFromUrl(_videoUrlController.text.trim())
                : null,
            thumbnailUrl: _mediaType == 'video'
                ? _thumbnailUrlController.text.trim()
                : null,
            targetUrl: _targetUrlController.text.trim(),
            startDate: _startDateForPackage(),
            endDate: _endDateForPackage(_durationDays),
            displayCurrency: _displayCurrency,
            displayTotalAmount: _displayTotalAmountForPackage(_durationDays),
            purchase: purchase,
          );
      ref.invalidate(advertPlacementRequestsProvider);
      if (mounted) {
        AppSnackbars.showSuccess(context, 'Advert request submitted');
      }
    } on DioException catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, _dioMessage(e));
      }
    } catch (_) {
      if (mounted) {
        AppSnackbars.showError(context, 'Unable to submit advert request');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _startDateForPackage() {
    final now = DateTime.now().toUtc();
    return _formatDate(now);
  }

  num _displayTotalAmountForPackage(int days) {
    switch (days) {
      case 1:
        return 35000;
      case 3:
        return 105000;
      case 7:
        return 245000;
      case 14:
        return 490000;
      case 30:
        return 1050000;
      default:
        return 0;
    }
  }

  String _endDateForPackage(int days) {
    final now = DateTime.now().toUtc();
    return _formatDate(now.add(Duration(days: days - 1)));
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _videoSourceFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube') || lower.contains('youtu.be')) {
      return 'youtube';
    }
    return 'url';
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
    return 'Unable to submit advert request';
  }
}

class _ServiceFormCard extends StatelessWidget {
  const _ServiceFormCard({required this.title, required this.child});

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

class _ServiceDropdown extends StatelessWidget {
  const _ServiceDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

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
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          dropdownColor: colors.surfaceElevated,
          decoration: InputDecoration(
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
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({
    required this.days,
    required this.isSelected,
    required this.onTap,
  });

  final int days;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? colors.accent : colors.border),
        ),
        child: Text(
          days == 1 ? '1 day' : '$days days',
          style: TextStyle(
            color: isSelected ? colors.onAccent : colors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
