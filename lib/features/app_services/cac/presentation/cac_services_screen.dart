import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/app_services/presentation/screens/app_service_ui.dart';

import '../data/cac_services_api.dart';
import '../domain/cac_registration_request.dart';
import 'controllers/cac_payment_controller.dart';
import 'controllers/cac_requests_controller.dart';

class CacServicesScreen extends ConsumerStatefulWidget {
  const CacServicesScreen({super.key});

  @override
  ConsumerState<CacServicesScreen> createState() => _CacServicesScreenState();
}

class _CacServicesScreenState extends ConsumerState<CacServicesScreen> {
  static const _businessObjectiveText =
      'To engage in the production, sale, supply and distribution of goods and services, retail and wholesale trade, marketing and other lawful business activities.';

  final _firstChoiceController = TextEditingController();
  final _secondChoiceController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerDobController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _ownerNinController = TextEditingController();
  bool _nameModificationAllowed = true;
  bool _consentAccepted = false;
  String _gender = 'female';
  bool _isSubmitting = false;
  String? _passportUrl;
  String? _identityUrl;
  String? _signatureUrl;
  // Upload loading state per document type
  final Map<String, bool> _uploadingTypes = {};

  @override
  void initState() {
    super.initState();
    _objectiveController.text = _businessObjectiveText;
  }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(cacRequestsProvider);

    return AppPageScaffold(
      title: 'CAC Registration',
      scrollable: true,
      child: requestsAsync.when(
        loading: () => const ServiceListSkeleton(),
        error: (error, stackTrace) => ServiceErrorState(
          message: 'Unable to load CAC requests',
          onRetry: () {
            ref.invalidate(cacRequestsProvider);
          },
        ),
        data: (items) {
          final latest = items.isEmpty ? null : items.first;
          final hasRequest = latest != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: hasRequest
                ? _buildRegisteredState(latest)
                : _buildRegistrationForm(context),
          );
        },
      ),
    );
  }

  List<Widget> _buildRegisteredState(CacRegistrationRequest request) {
    return [
      const ServiceIntroCard(
        title: 'CAC request received',
        description:
            'Your CAC registration is already on file. Track the review status here instead of filling the form again.',
        badge: 'CAC Service',
      ),
      const SizedBox(height: 20),
      SectionTitle(
        title: 'Application status',
        actionLabel: 'Refresh',
        onAction: () => ref.invalidate(cacRequestsProvider),
      ),
      const SizedBox(height: 12),
      StatusCard(
        title: request.firstChoiceName,
        subtitle: [
          if (request.secondChoiceName.isNotEmpty) request.secondChoiceName,
          if ((request.adminNote ?? '').isNotEmpty) request.adminNote!,
        ].join(' · '),
        status: request.status,
        reference: request.applicationReference,
      ),
    ];
  }

  List<Widget> _buildRegistrationForm(BuildContext context) {
    final colors = context.appColors;
    return [
      const ServiceIntroCard(
        title: 'Register a new business name',
        description:
            'Fill in your CAC details, upload the required documents, review the consent clause, and then continue to payment.',
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
              hint: 'WAWUBeauty Ventures',
            ),
            const SizedBox(height: 12),
            _ServiceField(
              controller: _secondChoiceController,
              label: 'Second choice name',
              hint: 'WAWUBeauty Creative Hub',
            ),
            const SizedBox(height: 12),
            _ServiceField(
              controller: _objectiveController,
              label: 'Business objective',
              hint: _businessObjectiveText,
              minLines: 4,
              maxLines: 6,
              readOnly: true,
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
                  child: _PickerField(
                    controller: _ownerDobController,
                    label: 'Date of birth',
                    hint: 'Select date of birth',
                    onTap: _pickOwnerDob,
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
            _PickerValueField(
              value: _gender == 'female' ? 'Female' : 'Male',
              label: 'Gender',
              hint: 'Select gender',
              onTap: () async {
                final next = await SelectionBottomSheet.show(
                  context,
                  title: 'Select gender',
                  options: const ['Female', 'Male'],
                  selected: _gender == 'female' ? 'Female' : 'Male',
                );
                if (next == null) return;
                setState(() {
                  _gender = next.toLowerCase();
                });
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _FormCard(
        title: 'Required documents',
        child: Column(
          children: [
            _UploadCard(
              label: 'Passport photograph',
              selectedUrl: _passportUrl,
              onTap: () => _uploadDocument('passport_photograph'),
              isLoading: _uploadingTypes['passport_photograph'] ?? false,
            ),
            const SizedBox(height: 12),
            _UploadCard(
              label: 'Means of identification',
              selectedUrl: _identityUrl,
              onTap: () => _uploadDocument('means_of_identification'),
              isLoading: _uploadingTypes['means_of_identification'] ?? false,
            ),
            const SizedBox(height: 12),
            _UploadCard(
              label: 'Signature',
              selectedUrl: _signatureUrl,
              onTap: () => _uploadDocument('signature'),
              isLoading: _uploadingTypes['signature'] ?? false,
            ),
            const SizedBox(height: 12),
            Text(
              'All signatures must be clearly written on plain white paper before upload. Blurred, cropped, or dark-background signatures will not be accepted and may lead to rejection.',
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
      _FormCard(
        title: 'Consent',
        child: CheckboxListTile(
          value: _consentAccepted,
          onChanged: (value) {
            setState(() {
              _consentAccepted = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          activeColor: colors.accent,
          checkColor: colors.onAccent,
          title: Text(
            'I acknowledge that a name availability search will be conducted before submission. If the proposed business name is rejected by the CAC, I hereby authorize WAWUBeauty to make necessary modifications including adding, removing, or rearranging words to the name and resubmit it on my behalf to ensure successful registration and approval.',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'I Accept',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
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
    ];
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
        _ownerNinController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Fill all CAC request fields first');
      return;
    }
    if ((_passportUrl ?? '').isEmpty ||
        (_identityUrl ?? '').isEmpty ||
        (_signatureUrl ?? '').isEmpty) {
      AppSnackbars.showError(
        context,
        'Upload the required CAC documents before continuing',
      );
      return;
    }
    if (!_consentAccepted) {
      AppSnackbars.showError(
        context,
        'You need to accept the CAC consent clause before continuing',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final paymentUrl = await ref
          .read(cacPaymentControllerProvider.notifier)
          .startCheckout(
            PendingCacRequest(
              firstChoiceName: _firstChoiceController.text.trim(),
              secondChoiceName: _secondChoiceController.text.trim(),
              acceptedNameModificationAuthorization: _nameModificationAllowed,
              consentToProcessRequest: _consentAccepted,
              businessObjective: _objectiveController.text.trim(),
              proprietors: [
                {
                  'full_name': _ownerNameController.text.trim(),
                  'date_of_birth': _ownerDobController.text.trim(),
                  'gender': _gender,
                  'phone_number': _ownerPhoneController.text.trim(),
                  'email_address': _ownerEmailController.text.trim(),
                  'residential_address': _ownerAddressController.text.trim(),
                  'passport_photograph_url': _passportUrl,
                  'means_of_identification_url': _identityUrl,
                  'signature_url': _signatureUrl,
                  'nin': _ownerNinController.text.trim(),
                },
              ],
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
          'Complete payment via Flutterwave to finish your CAC request',
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

  Future<void> _uploadDocument(String type) async {
    final path = await pickSingleFilePath();
    if (path == null) return;
    setState(() => _uploadingTypes[type] = true);
    try {
      final upload = await ref
          .read(cacServicesApiProvider)
          .uploadDocument(filePath: path, type: type);
      final url = upload['url'] as String?;
      if (url == null || url.isEmpty) {
        if (mounted) setState(() => _uploadingTypes[type] = false);
        if (mounted) AppSnackbars.showError(context, 'Upload failed');
        return;
      }
      if (!mounted) return;
      setState(() {
        _uploadingTypes[type] = false;
        switch (type) {
          case 'passport_photograph':
            _passportUrl = url;
            break;
          case 'means_of_identification':
            _identityUrl = url;
            break;
          case 'signature':
            _signatureUrl = url;
            break;
        }
      });
      AppSnackbars.showSuccess(context, 'Document uploaded');
    } on DioException catch (e) {
      if (mounted) setState(() => _uploadingTypes[type] = false);
      if (mounted) AppSnackbars.showError(context, _dioMessage(e));
    } catch (_) {
      if (mounted) setState(() => _uploadingTypes[type] = false);
      if (mounted) AppSnackbars.showError(context, 'Unable to upload document');
    }
  }

  Future<void> _pickOwnerDob() async {
    final initial =
        DateTime.tryParse(_ownerDobController.text.trim()) ??
        DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    final year = picked.year.toString().padLeft(4, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    setState(() {
      _ownerDobController.text = '$year-$month-$day';
    });
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

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.label,
    required this.selectedUrl,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final String? selectedUrl;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final uploaded = (selectedUrl ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
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
                      SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111111))),
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
                            Text(label,
                                style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              uploaded ? 'Uploaded ✓  Tap to change' : 'Tap to choose a file',
                              style: TextStyle(color: uploaded ? colors.accent : colors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(uploaded ? Icons.check_circle : Icons.upload_file,
                          color: uploaded ? colors.accent : colors.textSecondary),
                    ],
                  ),
          ),
        ),
        // Image preview after successful upload
        if (uploaded) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              selectedUrl!,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, prog) =>
                  prog == null ? child
                  : Container(height: 110, color: colors.surface,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111111)))),
              errorBuilder: (ctx, e, st) => Container(
                height: 60,
                decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Icon(Icons.broken_image_outlined, color: colors.textTertiary)),
              ),
            ),
          ),
        ],
      ],
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

class _ServiceField extends StatelessWidget {
  const _ServiceField({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int maxLines;
  final bool readOnly;

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
          readOnly: readOnly,
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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onTap;

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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: colors.textTertiary),
                filled: true,
                fillColor: colors.surfaceSecondary,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: colors.textSecondary,
                ),
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
          ),
        ),
      ],
    );
  }
}

class _PickerValueField extends StatelessWidget {
  const _PickerValueField({
    required this.value,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final String value;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = value.trim().isNotEmpty;
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value : hint,
                    style: TextStyle(
                      color: hasValue
                          ? colors.textPrimary
                          : colors.textTertiary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
