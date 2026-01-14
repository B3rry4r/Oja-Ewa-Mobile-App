import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/auth/auth_controller.dart';
import 'package:ojaewa/core/auth/auth_state.dart';
import 'package:ojaewa/core/widgets/selection_bottom_sheet.dart';
import 'package:ojaewa/features/home/subfeatures/schools/presentation/controllers/school_registration_controller.dart';

/// School Registration Form Screen - Collects user details for school enrollment
class SchoolRegistrationFormScreen extends ConsumerStatefulWidget {
  const SchoolRegistrationFormScreen({super.key, this.businessId});

  /// The business ID of the school being registered for
  final int? businessId;

  @override
  ConsumerState<SchoolRegistrationFormScreen> createState() => _SchoolRegistrationFormScreenState();
}

class _SchoolRegistrationFormScreenState extends ConsumerState<SchoolRegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String selectedCountry = 'Nigeria';
  String selectedState = 'FCT';
  String selectedCountryCode = '+234';
  
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
              showActions: false,
              title: Text(
                'Register',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ),
            
            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Subtitle
                      const Text(
                        'Fill in your details to continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E2021),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Country Dropdown
                      _buildDropdownField(
                        label: 'Country',
                        value: selectedCountry,
                        items: ['Nigeria', 'Ghana', 'Kenya', 'South Africa'],
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
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
                      _buildDropdownField(
                        label: 'State',
                        value: selectedState,
                        items: ['FCT', 'Lagos', 'Rivers', 'Kano'],
                        onChanged: (value) {
                          setState(() {
                            selectedState = value;
                          });
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final selected = await SelectionBottomSheet.show(
              context,
              title: label,
              options: items,
              selected: value,
            );
            if (selected != null && selected != value) {
              onChanged(selected);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF1E2021),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E2021),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFFCCCCCC),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Country code selector
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final selected = await SelectionBottomSheet.show(
                    context,
                    title: 'Country code',
                    options: const ['+234', '+233', '+254', '+27'],
                    selected: selectedCountryCode,
                  );
                  if (selected != null && selected != selectedCountryCode) {
                    setState(() {
                      selectedCountryCode = selected;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  child: Row(
                    children: [
                      Text(
                        selectedCountryCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF241508),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF1E2021),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E2021),
                  ),
                  decoration: const InputDecoration(
                    hintText: '8167654354',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFCCCCCC),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
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
    final registrationState = ref.watch(schoolRegistrationProvider);
    final isLoading = registrationState.isSubmitting || registrationState.isGeneratingPaymentLink;

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
          backgroundColor: const Color(0xFFFDAF40),
          disabledBackgroundColor: const Color(0xFFFDAF40).withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFFDAF40).withAlpha(77),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFBF5)),
                ),
              )
            : const Text(
                'Make Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFBF5),
                ),
              ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    final notifier = ref.read(schoolRegistrationProvider.notifier);
    
    // Build full phone number
    final fullPhoneNumber = '$selectedCountryCode${_phoneController.text}';

    // Step 1: Submit registration
    final success = await notifier.submitRegistration(
      country: selectedCountry,
      fullName: _nameController.text,
      phoneNumber: fullPhoneNumber,
      userState: selectedState,
      city: _cityController.text,
      address: _addressController.text,
      businessId: widget.businessId,
    );

    if (!success) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to submit registration. Please try again.');
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
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Enter Your Email',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We need your email to send payment confirmation.',
              style: TextStyle(fontFamily: 'Campton'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'email@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Campton',
                color: Color(0xFF777F84),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                Navigator.of(context).pop(email);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'Campton',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPaymentConfirmationDialog({required bool requiresLogin}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Registration Submitted',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          requiresLogin
              ? 'Your registration has been submitted. Please log in to complete payment (₦500).'
              : 'Your registration has been submitted successfully.',
          style: const TextStyle(
            fontFamily: 'Campton',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to school detail
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Campton',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      // Show success dialog after opening payment
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Payment Initiated',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Complete the payment in your browser. The registration fee is ₦500.',
            style: TextStyle(
              fontFamily: 'Campton',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to school detail
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDAF40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'Campton',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _showErrorSnackbar('Could not open payment page.');
    }
  }
}