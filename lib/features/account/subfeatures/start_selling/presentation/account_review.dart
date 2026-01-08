// account_review_screen.dart
import 'package:flutter/material.dart';

class AccountReviewScreen extends StatelessWidget {
  const AccountReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              // Success illustration placeholder
              _buildSuccessIllustration(),
              
              // Success message
              _buildSuccessMessage(),
              
              // Go Home button
              _buildGoHomeButton(context),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (hidden for completion screen - using placeholder)
          Opacity(
            opacity: 0,
            child: _buildIconButton(context, Icons.arrow_back_ios_new_rounded),
          ),
          
          // Empty container for spacing (no title in header)
          const SizedBox(width: 40),
          
          // Close button
          _buildIconButton(context, Icons.close_rounded),
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
              
              // Step 2 (completed - inactive)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9E9),
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
              
              // Step 3 (current - active with checkmark)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF603814),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFFF4F4F4),
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
              
              // Step 2 label (inactive)
              Text(
                'Business\nDetails',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF777F84),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 53),
              
              // Step 3 label (active - completed)
              const Text(
                'Account\non review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF603814),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return Container(
      margin: const EdgeInsets.only(top: 170),
      width: double.infinity,
      height: 425,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Main illustration container
          Container(
            width: double.infinity,
            height: 425,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF603814),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Placeholder for illustration image
                const Text(
                  '✨ Success Illustration ✨',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF603814),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '(Illustration would appear here)',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    color: Color(0xFF777F84),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.symmetric(horizontal: 54),
      child: const Text(
        'We are reviewing your application\nThis takes 12-24 hours.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Campton',
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildGoHomeButton(BuildContext context) {
    return Container(
      width: 342,
      margin: const EdgeInsets.only(top: 126),
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
            // Navigate to home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: const Text(
              'Go Home',
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

  Widget _buildIconButton(BuildContext context, IconData icon) {
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
        onPressed: () {
          // Close the entire registration flow
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        padding: EdgeInsets.zero,
      ),
    );
  }
}