import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// School Registration Form Screen - Collects user details for school enrollment
class SchoolRegistrationFormScreen extends StatefulWidget {
  const SchoolRegistrationFormScreen({super.key});

  @override
  State<SchoolRegistrationFormScreen> createState() => _SchoolRegistrationFormScreenState();
}

class _SchoolRegistrationFormScreenState extends State<SchoolRegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String selectedCountry = 'Nigeria';
  String selectedState = 'FCT';
  
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
            _buildTopAppBar(),
            
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
                            selectedCountry = value!;
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
                            selectedState = value!;
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

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDEDEDE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF241508),
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          
          const Spacer(),
          
          // Title
          const Text(
            'Form',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          
          const Spacer(),
          
          // Placeholder for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF1E2021),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E2021),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
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
              // Country Flag and Code
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    // Flag placeholder (you can use actual flag asset)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xFF1E2021),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+234',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF241508),
                      ),
                    ),
                  ],
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
              
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process payment
            _handlePayment();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFDAF40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFFDAF40).withOpacity(0.3),
        ),
        child: const Text(
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

  void _handlePayment() {
    // Show success dialog or navigate to payment screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Proceed to Payment',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Your registration details have been submitted. Proceed to payment?',
          style: TextStyle(
            fontFamily: 'Campton',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
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
              Navigator.of(context).pop();
              // Navigate to payment screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Proceed',
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
}