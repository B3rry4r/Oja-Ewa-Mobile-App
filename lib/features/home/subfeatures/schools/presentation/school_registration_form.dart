import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_state.dart';
import 'package:ojaewa/core/location/location_picker_sheets.dart';
import 'package:ojaewa/features/home/subfeatures/schools/presentation/controllers/school_registration_controller.dart';

/// School Registration Form Screen - Collects user details for school enrollment
class SchoolRegistrationFormScreen extends ConsumerStatefulWidget {
  const SchoolRegistrationFormScreen({super.key, this.businessId});

  /// The business ID of the school being registered for
  final int? businessId;

  @override
  ConsumerState<SchoolRegistrationFormScreen> createState() =>
      _SchoolRegistrationFormScreenState();
}

class _SchoolRegistrationFormScreenState
    extends ConsumerState<SchoolRegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Location selections
  // Location selections - empty by default
  String _selectedCountryName = '';
  String _selectedStateName = '';
  String _selectedCountryCode = '';
  String _selectedCountryFlag = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'Register',
      showActions: false,
      scrollable: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Subtitle
            Text(
              'Fill in your details to continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // Country Dropdown
            _buildLocationDropdown(
              label: 'Country',
              value: _selectedCountryName,
              flag: _selectedCountryFlag,
              onTap: () async {
                final country = await CountryPickerSheet.show(
                  context,
                  selectedCountry: _selectedCountryName,
                );
                if (country != null) {
                  setState(() {
                    _selectedCountryName = country.name;
                    _selectedCountryFlag = country.flag;
                    _selectedCountryCode = country.dialCode;
                    _selectedStateName = ''; // Reset state when country changes
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            // Full Name Field
            _buildTextField(
              label: 'Full Name',
              controller: _nameController,
              placeholder: 'Your Name here',
            ),

            const SizedBox(height: 24),

            // Phone Number Field
            _buildPhoneField(),

            const SizedBox(height: 24),

            // State Dropdown
            _buildLocationDropdown(
              label: 'State',
              value: _selectedStateName.isEmpty
                  ? 'Select State'
                  : _selectedStateName,
              onTap: () async {
                final state = await StatePickerSheet.show(
                  context,
                  countryName: _selectedCountryName,
                  selectedState: _selectedStateName,
                );
                if (state != null) {
                  setState(() {
                    _selectedStateName = state.name;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            // City Field
            _buildTextField(
              label: 'City',
              controller: _cityController,
              placeholder: 'Your City',
            ),

            const SizedBox(height: 24),

            // Address Line Field
            _buildTextField(
              label: 'Address Line',
              controller: _addressController,
              placeholder: 'Street, house number etc',
            ),

            const SizedBox(height: 40),

            // Make Payment Button
            _buildPaymentButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required String value,
    String? flag,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                if (flag != null) ...[
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: colors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Country code selector
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final country = await CountryCodePickerSheet.show(
                    context,
                    selectedDialCode: _selectedCountryCode,
                  );
                  if (country != null) {
                    setState(() {
                      _selectedCountryCode = country.dialCode;
                      _selectedCountryFlag = country.flag;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  child: Row(
                    children: [
                      Text(
                        _selectedCountryFlag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountryCode,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Phone Number Input
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '8167654354',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    final colors = context.appColors;
    final registrationState = ref.watch(schoolRegistrationProvider);
    final isLoading =
        registrationState.isSubmitting ||
        registrationState.isGeneratingPaymentLink;

    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  _handlePayment();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          disabledBackgroundColor: colors.accent.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: colors.accent.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.onAccent),
                ),
              )
            : Text(
                'Make Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onAccent,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    final notifier = ref.read(schoolRegistrationProvider.notifier);

    // Build full phone number
    final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';

    // Step 1: Submit registration
    final success = await notifier.submitRegistration(
      country: _selectedCountryName,
      fullName: _nameController.text,
      phoneNumber: fullPhoneNumber,
      userState: _selectedStateName,
      city: _cityController.text,
      address: _addressController.text,
      businessId: widget.businessId,
    );

    if (!success) {
      if (!mounted) return;
      final err = ref.read(schoolRegistrationProvider).error;
      _showErrorSnackbar(
        err ?? 'Failed to submit registration. Please try again.',
      );
      return;
    }

    // Step 2: Check if user is authenticated for payment link
    final authState = ref.read(authControllerProvider);
    final isAuthenticated = authState is AuthAuthenticated;
    if (!isAuthenticated) {
      if (!mounted) return;
      _showPaymentConfirmationDialog(requiresLogin: true);
      return;
    }

    // Step 3: Generate payment link - prompt for email since we don't store it in auth state
    if (!mounted) return;
    final email = await _promptForEmail();
    if (email == null || email.isEmpty) {
      return;
    }

    final paymentUrl = await notifier.createPaymentLink(email: email);

    if (paymentUrl != null) {
      if (!mounted) return;
      _openPaymentUrl(paymentUrl);
    } else {
      if (!mounted) return;
      _showErrorSnackbar('Failed to generate payment link. Please try again.');
    }
  }

  Future<String?> _promptForEmail() async {
    final emailController = TextEditingController();
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'EmailPrompt',
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        final colors = context.appColors;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Enter Your Email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We need your email to send payment confirmation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'email@example.com',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: colors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(null),
                            child: Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: colors.border),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final email = emailController.text.trim();
                              if (email.isNotEmpty && email.contains('@')) {
                                Navigator.of(context).pop(email);
                              }
                            },
                            child: Container(
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
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showPaymentConfirmationDialog({required bool requiresLogin}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'RegistrationSubmitted',
      barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
      pageBuilder: (context, anim1, anim2) {
        final colors = context.appColors;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 342,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Registration Submitted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      requiresLogin
                          ? 'Your registration has been submitted. Please log in to complete payment (₦500).'
                          : 'Your registration has been submitted successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Go back to school detail
                      },
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
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.onAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      // Show success dialog after opening payment
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'PaymentInitiated',
        barrierColor: context.appColors.shadow.withValues(alpha: 0.82),
        pageBuilder: (context, anim1, anim2) {
          final colors = context.appColors;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: 342,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Color(0xFF111111),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Payment Initiated',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Complete the payment in your browser. The registration fee is ₦500.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(
                            context,
                          ).pop(); // Go back to school detail
                        },
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
                              'Done',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.onAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      _showErrorSnackbar('Could not open payment page.');
    }
  }
}
