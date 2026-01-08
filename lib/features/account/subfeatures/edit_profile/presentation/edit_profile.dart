// edit_profile_screen.dart
import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background image
            Positioned(
              right: -30,
              bottom: -100,
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  width: 234,
                  height: 347,
                  color: Colors.grey[300], // Placeholder for image
                  child: const Placeholder(),
                ),
              ),
            ),
            
            // Main content
            Column(
              children: [
                // Header with buttons and title
                Container(
                  height: 104,
                  padding: const EdgeInsets.only(top: 32),
                  child: Stack(
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _buildIconButton(Icons.arrow_back),
                        ),
                      ),
                      
                      // Title
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                      ),
                      
                      // Right button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildIconButton(Icons.more_vert),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Full Name field
                        const SizedBox(height: 20), // 100 - 104 + 16
                        _buildFormField(
                          label: 'Full Name',
                          value: 'sanusimot@gmail.com',
                          isEmail: true,
                        ),
                        
                        // Email field
                        const SizedBox(height: 19), // 194 - 100 - 75
                        _buildFormField(
                          label: 'Email',
                          value: 'sanusimot@gmail.com',
                          isEmail: true,
                        ),
                        
                        // Phone Number field
                        const SizedBox(height: 19), // 288 - 194 - 75
                        _buildPhoneField(),
                        
                        // Save button
                        const SizedBox(height: 60), // 423 - 288 - 75
                        _buildSaveButton(),
                        
                        // Bottom spacing
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        icon: Icon(icon, size: 20),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String value,
    bool isEmail = false,
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
          height: 49,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: isEmail ? const Color(0xFFCCCCCC) : const Color(0xFF241508),
              ),
            ),
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
          height: 49,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            children: [
              // Country flag and code
              Container(
                width: 44,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    // Country flag placeholder
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Dropdown arrow
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                    ),
                  ],
                ),
              ),
              
              // Phone number
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '+234',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF241508),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '8167654354',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
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

  Widget _buildSaveButton() {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: const Center(
            child: Text(
              'Save Changes',
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
}