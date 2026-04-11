import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/app_services/presentation/screens/app_service_ui.dart';

import 'controllers/cac_payment_controller.dart';
import 'controllers/cac_requests_controller.dart';

class CacServicesScreen extends ConsumerStatefulWidget {
  const CacServicesScreen({super.key});

  @override
  ConsumerState<CacServicesScreen> createState() => _CacServicesScreenState();
}

class _CacServicesScreenState extends ConsumerState<CacServicesScreen> {
  final _firstChoiceController = TextEditingController();
  final _secondChoiceController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerDobController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _ownerNinController = TextEditingController();
  final _passportPhotoUrlController = TextEditingController();
  final _meansOfIdUrlController = TextEditingController();
  final _signatureUrlController = TextEditingController();
  bool _nameModificationAllowed = true;
  String _gender = 'female';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstChoiceController.dispose();
    _secondChoiceController.dispose();
    _objectiveController.dispose();
    _ownerNameController.dispose();
    _ownerDobController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _ownerAddressController.dispose();
    _ownerNinController.dispose();
    _passportPhotoUrlController.dispose();
    _meansOfIdUrlController.dispose();
    _signatureUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(cacRequestsProvider);
    final colors = context.appColors;

    return AppPageScaffold(
      title: 'CAC Registration',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceIntroCard(
            title: 'Register a new business name',
            description:
                'Fill in your business name choices and proprietor details here, then complete payment before submission.',
            badge: 'CAC Service',
          ),
          const SizedBox(height: 20),
          _FormCard(
            title: 'Business details',
            child: Column(
              children: [
                _ServiceField(
                  controller: _firstChoiceController,
                  label: 'First choice name',
                  hint: 'Oja Ewa Ventures',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _secondChoiceController,
                  label: 'Second choice name',
                  hint: 'Oja Ewa Creative Hub',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _objectiveController,
                  label: 'Business objective',
                  hint: 'Describe the purpose of the business',
                  minLines: 4,
                  maxLines: 6,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _nameModificationAllowed,
                  onChanged: (value) {
                    setState(() {
                      _nameModificationAllowed = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: colors.accent,
                  checkColor: colors.onAccent,
                  title: Text(
                    'Allow minor name modification if required',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Use this if you want admin to proceed with the closest available CAC name where needed.',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Proprietor details',
            child: Column(
              children: [
                _ServiceField(
                  controller: _ownerNameController,
                  label: 'Full name',
                  hint: 'Ada Okafor',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ServiceField(
                        controller: _ownerDobController,
                        label: 'Date of birth',
                        hint: '1990-01-01',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ServiceField(
                        controller: _ownerNinController,
                        label: 'NIN',
                        hint: '12345678901',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ServiceField(
                        controller: _ownerPhoneController,
                        label: 'Phone number',
                        hint: '08012345678',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ServiceField(
                        controller: _ownerEmailController,
                        label: 'Email address',
                        hint: 'ada@example.com',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _ownerAddressController,
                  label: 'Residential address',
                  hint: '12 Allen Avenue, Lagos',
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _ServiceDropdown(
                  label: 'Gender',
                  value: _gender,
                  items: const ['female', 'male'],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _gender = value);
                  },
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _passportPhotoUrlController,
                  label: 'Passport photograph URL',
                  hint: 'https://example.com/passport.jpg',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _meansOfIdUrlController,
                  label: 'Means of identification URL',
                  hint: 'https://example.com/id.jpg',
                ),
                const SizedBox(height: 12),
                _ServiceField(
                  controller: _signatureUrlController,
                  label: 'Signature URL',
                  hint: 'https://example.com/signature.jpg',
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
                  : const Text('Pay & Submit CAC Request'),
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Your requests',
            actionLabel: 'Refresh',
            onAction: () {
              ref.invalidate(cacRequestsProvider);
            },
          ),
          const SizedBox(height: 12),
          requestsAsync.when(
            loading: () => const ServiceListSkeleton(),
            error: (error, stackTrace) => ServiceErrorState(
              message: 'Unable to load CAC requests',
              onRetry: () {
                ref.invalidate(cacRequestsProvider);
              },
            ),
            data: (items) {
              if (items.isEmpty) {
                return const ServiceEmptyState(
                  title: 'No CAC requests yet',
                  description:
                      'Once a request is submitted, its review status and reference will show here.',
                );
              }
              return Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StatusCard(
                        title: item.firstChoiceName,
                        subtitle: item.secondChoiceName.isEmpty
                            ? null
                            : item.secondChoiceName,
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
    if (_firstChoiceController.text.trim().isEmpty ||
        _secondChoiceController.text.trim().isEmpty ||
        _objectiveController.text.trim().isEmpty ||
        _ownerNameController.text.trim().isEmpty ||
        _ownerDobController.text.trim().isEmpty ||
        _ownerPhoneController.text.trim().isEmpty ||
        _ownerEmailController.text.trim().isEmpty ||
        _ownerAddressController.text.trim().isEmpty ||
        _ownerNinController.text.trim().isEmpty ||
        _passportPhotoUrlController.text.trim().isEmpty ||
        _meansOfIdUrlController.text.trim().isEmpty ||
        _signatureUrlController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Fill all CAC request fields first');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final email = await _resolveEmail();
      if (email == null || email.isEmpty) {
        if (mounted) {
          AppSnackbars.showError(context, 'Email is required for payment');
        }
        return;
      }

      final paymentUrl = await ref
          .read(cacPaymentControllerProvider.notifier)
          .startCheckout(
            PendingCacRequest(
              firstChoiceName: _firstChoiceController.text.trim(),
              secondChoiceName: _secondChoiceController.text.trim(),
              acceptedNameModificationAuthorization: _nameModificationAllowed,
              businessObjective: _objectiveController.text.trim(),
              proprietors: [
                {
                  'full_name': _ownerNameController.text.trim(),
                  'date_of_birth': _ownerDobController.text.trim(),
                  'gender': _gender,
                  'phone_number': _ownerPhoneController.text.trim(),
                  'email_address': _ownerEmailController.text.trim(),
                  'residential_address': _ownerAddressController.text.trim(),
                  'passport_photograph_url': _passportPhotoUrlController.text
                      .trim(),
                  'means_of_identification_url': _meansOfIdUrlController.text
                      .trim(),
                  'signature_url': _signatureUrlController.text.trim(),
                  'nin': _ownerNinController.text.trim(),
                },
              ],
              email: email,
            ),
          );

      if (paymentUrl == null || paymentUrl.isEmpty) {
        final err = ref.read(cacPaymentControllerProvider).error;
        if (mounted) {
          AppSnackbars.showError(
            context,
            err ?? 'Unable to initialize CAC payment',
          );
        }
        return;
      }

      final uri = Uri.tryParse(paymentUrl);
      if (uri == null) {
        if (mounted) {
          AppSnackbars.showError(context, 'Invalid payment link');
        }
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        AppSnackbars.showSuccess(
          context,
          'Complete payment in Paystack to finish your CAC request',
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, _dioMessage(e));
      }
    } catch (_) {
      if (mounted) {
        AppSnackbars.showError(context, 'Unable to submit CAC request');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String?> _resolveEmail() async {
    final profile = ref.read(userProfileProvider).value;
    final profileEmail = profile?.email.trim() ?? '';
    if (profileEmail.isNotEmpty) {
      return profileEmail;
    }
    return _promptForEmail();
  }

  Future<String?> _promptForEmail() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final colors = context.appColors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Enter your email',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: TextStyle(color: colors.textTertiary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
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
    return 'Unable to submit CAC request';
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
