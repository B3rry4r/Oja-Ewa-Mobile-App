import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/files/pick_file.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/app_services/presentation/screens/app_service_ui.dart';

import '../data/nepc_services_api.dart';
import '../domain/nepc_registration_request.dart';
import 'controllers/nepc_payment_controller.dart';
import 'controllers/nepc_requests_controller.dart';

class NepcServicesScreen extends ConsumerStatefulWidget {
  const NepcServicesScreen({super.key});

  @override
  ConsumerState<NepcServicesScreen> createState() => _NepcServicesScreenState();
}

class _NepcServicesScreenState extends ConsumerState<NepcServicesScreen> {
  final _businessNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _productsToExportController = TextEditingController();

  String _applicationType = 'new_registration';
  String _businessType = 'limited_liability_company';
  bool _confirmedInformation = false;
  bool _isSubmitting = false;
  final Map<String, String> _uploadedDocuments = {};

  static const _applicationTypes = {
    'new_registration': 'New registration',
    'renewal_under_3_months': 'Renewal under 3 months',
    'late_renewal_over_3_months': 'Late renewal over 3 months',
  };

  static const _businessTypes = {
    'limited_liability_company': 'Limited Liability Company',
    'cooperative_society': 'Cooperative Society',
    'government_ngo': 'Government / NGO',
  };

  static const _documentLabels = {
    'certificate_of_incorporation': 'Certificate of Incorporation',
    'memorandum_articles': 'Memorandum & Articles',
    'cac_1_1': 'CAC 1.1',
    'certificate_of_registration': 'Certificate of Registration',
    'bye_laws': 'Bye Laws',
    'constitution': 'Constitution',
    'memorandum_for_guidance': 'Memorandum for Guidance',
  };

  @override
  void dispose() {
    _businessNameController.dispose();
    _registrationNumberController.dispose();
    _businessAddressController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _productsToExportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(nepcRequestsProvider);

    return AppPageScaffold(
      title: 'NEPC Registration',
      scrollable: true,
      child: requestsAsync.when(
        loading: () => const ServiceListSkeleton(),
        error: (error, stackTrace) => ServiceErrorState(
          message: 'Unable to load NEPC requests',
          onRetry: () => ref.invalidate(nepcRequestsProvider),
        ),
        data: (items) {
          final latest = items.isEmpty ? null : items.first;
          final hasRequest = latest != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: hasRequest
                ? _buildRegisteredState(latest)
                : _buildApplicationForm(context),
          );
        },
      ),
    );
  }

  List<Widget> _buildRegisteredState(NepcRegistrationRequest request) {
    return [
      const ServiceIntroCard(
        title: 'NEPC application received',
        description:
            'Your NEPC application is already on file. Track the status here instead of starting the form again.',
        badge: 'NEPC',
      ),
      const SizedBox(height: 20),
      SectionTitle(
        title: 'Application status',
        actionLabel: 'Refresh',
        onAction: () => ref.invalidate(nepcRequestsProvider),
      ),
      const SizedBox(height: 12),
      StatusCard(
        title: request.businessName,
        subtitle: [
          '${_applicationTypes[request.applicationType] ?? request.applicationType} · ${_businessTypes[request.businessType] ?? request.businessType}',
          if ((request.adminNote ?? '').isNotEmpty) request.adminNote!,
          if ((request.certificateUrl ?? '').isNotEmpty)
            'Certificate available',
        ].join(' · '),
        status: request.status,
        reference: request.applicationReference,
      ),
      if ((request.certificateUrl ?? '').isNotEmpty) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              final uri = Uri.tryParse(request.certificateUrl!);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Open Certificate'),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildApplicationForm(BuildContext context) {
    final colors = context.appColors;
    return [
      const ServiceIntroCard(
        title: 'Get Your NEPC Export Certificate',
        description: 'Sell to the world. We handle the paperwork.',
        badge: 'NEPC',
      ),
      const SizedBox(height: 20),
      _Card(
        title: 'Benefits',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _BenefitLine(text: 'Export incentives'),
            SizedBox(height: 8),
            _BenefitLine(text: 'Free training (workshops, seminars)'),
            SizedBox(height: 8),
            _BenefitLine(text: 'Connect with other exporters'),
            SizedBox(height: 8),
            _BenefitLine(text: 'Direct links to international buyers'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Card(
        title: 'Application details',
        child: Column(
          children: [
            _PickerField(
              label: 'Application type',
              value: _applicationTypes[_applicationType]!,
              onTap: () => _pickApplicationType(context),
            ),
            const SizedBox(height: 12),
            _PickerField(
              label: 'Business type',
              value: _businessTypes[_businessType]!,
              onTap: () => _pickBusinessType(context),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _businessNameController,
              label: 'Business name',
              hint: 'Oja Ewa Exports Ltd',
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _registrationNumberController,
              label: 'Registration number',
              hint: 'RC123456',
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _businessAddressController,
              label: 'Business address',
              hint: 'No 1 Broad Street, Lagos',
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _fullNameController,
              label: 'Full name',
              hint: 'Ada Okafor',
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _phoneNumberController,
              label: 'Phone number',
              hint: '+2348012345678',
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _emailController,
              label: 'Email',
              hint: 'ada@example.com',
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _productsToExportController,
              label: 'Products to export',
              hint: 'Textiles and fashion accessories',
              minLines: 3,
              maxLines: 4,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Card(
        title: 'Required documents',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload the documents required for ${_businessTypes[_businessType]!.toLowerCase()}.',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            for (final type in _requiredDocumentTypes())
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UploadCard(
                  label: _documentLabels[type] ?? type,
                  selectedUrl: _uploadedDocuments[type],
                  onTap: () => _uploadDocument(type),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Card(
        title: 'Confirmation',
        child: CheckboxListTile(
          value: _confirmedInformation,
          onChanged: (value) {
            setState(() {
              _confirmedInformation = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
          activeColor: colors.accent,
          checkColor: colors.onAccent,
          title: Text(
            'I confirm all information is correct',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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
              : const Text('Pay & Submit NEPC Request'),
        ),
      ),
    ];
  }

  List<String> _requiredDocumentTypes() {
    switch (_businessType) {
      case 'cooperative_society':
        return const ['certificate_of_registration', 'bye_laws'];
      case 'government_ngo':
        return const [
          'certificate_of_registration',
          'constitution',
          'memorandum_for_guidance',
        ];
      default:
        return const [
          'certificate_of_incorporation',
          'memorandum_articles',
          'cac_1_1',
        ];
    }
  }

  Future<void> _pickApplicationType(BuildContext context) async {
    final next = await SelectionBottomSheet.show(
      context,
      title: 'Select application type',
      options: _applicationTypes.values.toList(),
      selected: _applicationTypes[_applicationType]!,
    );
    if (next == null) return;
    setState(() {
      _applicationType = _applicationTypes.entries
          .firstWhere((entry) => entry.value == next)
          .key;
    });
  }

  Future<void> _pickBusinessType(BuildContext context) async {
    final next = await SelectionBottomSheet.show(
      context,
      title: 'Select business type',
      options: _businessTypes.values.toList(),
      selected: _businessTypes[_businessType]!,
    );
    if (next == null) return;
    setState(() {
      _businessType = _businessTypes.entries
          .firstWhere((entry) => entry.value == next)
          .key;
      _uploadedDocuments.removeWhere(
        (key, _) => !_requiredDocumentTypes().contains(key),
      );
    });
  }

  Future<void> _uploadDocument(String type) async {
    final path = await pickSingleFilePath();
    if (path == null) return;
    try {
      final upload = await ref
          .read(nepcServicesApiProvider)
          .uploadDocument(filePath: path, type: type);
      final url = upload['url'] as String?;
      if (url == null || url.isEmpty) {
        if (mounted) {
          AppSnackbars.showError(context, 'Upload failed');
        }
        return;
      }
      if (!mounted) return;
      setState(() {
        _uploadedDocuments[type] = url;
      });
      AppSnackbars.showSuccess(context, 'Document uploaded');
    } on DioException catch (e) {
      if (mounted) AppSnackbars.showError(context, _dioMessage(e));
    } catch (_) {
      if (mounted) AppSnackbars.showError(context, 'Unable to upload document');
    }
  }

  Future<void> _submit() async {
    if (_businessNameController.text.trim().isEmpty ||
        _registrationNumberController.text.trim().isEmpty ||
        _businessAddressController.text.trim().isEmpty ||
        _fullNameController.text.trim().isEmpty ||
        _phoneNumberController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _productsToExportController.text.trim().isEmpty) {
      AppSnackbars.showError(context, 'Fill all NEPC request fields first');
      return;
    }
    final requiredDocs = _requiredDocumentTypes();
    final missingDocs = requiredDocs
        .where((type) => (_uploadedDocuments[type] ?? '').isEmpty)
        .toList();
    if (missingDocs.isNotEmpty) {
      AppSnackbars.showError(
        context,
        'Upload all required NEPC documents first',
      );
      return;
    }
    if (!_confirmedInformation) {
      AppSnackbars.showError(
        context,
        'Confirm the NEPC information clause before continuing',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final paymentUrl = await ref
          .read(nepcPaymentControllerProvider.notifier)
          .startCheckout(
            PendingNepcRequest(
              applicationType: _applicationType,
              businessType: _businessType,
              documents: requiredDocs
                  .map(
                    (type) => {'type': type, 'url': _uploadedDocuments[type]},
                  )
                  .toList(),
              businessName: _businessNameController.text.trim(),
              registrationNumber: _registrationNumberController.text.trim(),
              businessAddress: _businessAddressController.text.trim(),
              fullName: _fullNameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim(),
              email: _emailController.text.trim(),
              productsToExport: _productsToExportController.text.trim(),
              confirmedInformation: _confirmedInformation,
              amount: _amountForApplicationType(),
            ),
          );
      if (paymentUrl == null || paymentUrl.isEmpty) {
        final error = ref.read(nepcPaymentControllerProvider).error;
        if (mounted) {
          AppSnackbars.showError(
            context,
            error ?? 'Unable to initialize NEPC payment',
          );
        }
        return;
      }
      final uri = Uri.tryParse(paymentUrl);
      if (uri == null) {
        if (mounted) AppSnackbars.showError(context, 'Invalid payment link');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        AppSnackbars.showSuccess(
          context,
          'Complete payment in Paystack to finish your NEPC request',
        );
      }
    } on DioException catch (e) {
      if (mounted) AppSnackbars.showError(context, _dioMessage(e));
    } catch (_) {
      if (mounted) {
        AppSnackbars.showError(context, 'Unable to submit NEPC request');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  num _amountForApplicationType() {
    switch (_applicationType) {
      case 'renewal_under_3_months':
        return 17500;
      case 'late_renewal_over_3_months':
        return 22500;
      default:
        return 23500;
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
    return 'Unable to complete NEPC request';
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

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

class _BenefitLine extends StatelessWidget {
  const _BenefitLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
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
                    value,
                    style: TextStyle(color: colors.textPrimary),
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

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.label,
    required this.selectedUrl,
    required this.onTap,
  });

  final String label;
  final String? selectedUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasFile = (selectedUrl ?? '').isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasFile ? colors.accent : colors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  color: hasFile ? colors.accent : colors.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  hasFile ? 'Document uploaded' : 'Select document',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
