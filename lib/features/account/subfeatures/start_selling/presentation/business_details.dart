// business_details_screen.dart
import 'package:flutter/material.dart';

import '../../../../../app/router/app_router.dart';

class BusinessDetailsScreen extends StatelessWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              // Form content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About Business section title
                    const SizedBox(height: 64),
                    _buildSectionTitle('About Business'),
                    const SizedBox(height: 35),
                    
                    // Business Name field
                    _buildLabeledInput(
                      label: 'Business Name',
                      hintText: 'Your City', // From IR data - likely placeholder text
                    ),
                    const SizedBox(height: 24),
                    
                    // Business Registration Number field
                    _buildLabeledInput(
                      label: 'Business Registration Number',
                      hintText: 'Your City', // From IR data - likely placeholder text
                    ),
                    const SizedBox(height: 99),
                    
                    // Business Certificate upload
                    _buildUploadSection(
                      title: 'Business Certificate',
                      browseText: 'Browse Document',
                      leftRequirements: 'High resolution image\nPDF, JPG, PNG formats',
                      rightRequirements: '200 x 200px\n20kb max',
                    ),
                    const SizedBox(height: 24),
                    
                    // Business Logo upload
                    _buildUploadSection(
                      title: 'Business Logo',
                      browseText: 'Browse Document',
                      leftRequirements: 'High resolution image\nPNG format',
                      rightRequirements: '200 x 200px\nMust be in Black',
                    ),
                    
                    // Account Details section title
                    const SizedBox(height: 32),
                    _buildSectionTitle('Account Details'),
                    const SizedBox(height: 35),
                    
                    // Bank Name field
                    _buildLabeledInput(
                      label: 'Bank Name',
                      hintText: 'Your Bank',
                    ),
                    const SizedBox(height: 24),
                    
                    // Account Number field
                    _buildLabeledInput(
                      label: 'Account Number',
                      hintText: 'Your Account Number',
                    ),
                    const SizedBox(height: 135),
                    
                    // Make Payment button
                    _buildPaymentButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _buildIconButton(Icons.arrow_back_ios_new_rounded),
          
          // Empty container for spacing (no title in header)
          const SizedBox(width: 40),
          
          // Close button
          _buildIconButton(Icons.close_rounded),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 101, 17, 0),
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step 1 (completed - inactive)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF4F4F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 37),
              
              // Step 2 (current - active)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF603814),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF4F4F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 37),
              
              // Step 3 (inactive)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF4F4F4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step 1 label (inactive)
              Text(
                'Basic\nInfo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF777F84),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 52),
              
              // Step 2 label (active)
              const Text(
                'Business\nDetails',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF603814),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 53),
              
              // Step 3 label (inactive)
              Text(
                'Account\non review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF777F84),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'Campton',
        fontWeight: FontWeight.w600,
        color: Color(0xFF3C4042),
      ),
    );
  }

  Widget _buildLabeledInput({
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        
        // Text field container
        Container(
          height: 49,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  color: Color(0xFFCCCCCC),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String browseText,
    required String leftRequirements,
    required String rightRequirements,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        
        // Upload container
        Container(
          height: 137,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF89858A)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Upload icon
              const Icon(
                Icons.upload_rounded,
                size: 24,
                color: Color(0xFF1E2021),
              ),
              const SizedBox(height: 8),
              
              // Browse text
              Text(
                browseText,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  color: Color(0xFF1E2021),
                ),
              ),
              
              // Format requirements
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left requirements
                    Text(
                      leftRequirements,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Campton',
                        color: Color(0xFF777F84),
                        height: 1.4,
                      ),
                    ),
                    
                    // Right requirements
                    Text(
                      rightRequirements,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Campton',
                        color: Color(0xFF777F84),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.accountReview);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
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
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDEDEDE)),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
        ),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}