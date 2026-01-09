// write_review_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class WriteReviewScreen extends StatelessWidget {
  const WriteReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814), // Main background color
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(iconColor: Colors.white),

            // Main content card (rounded top corners)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1), // Card background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'Write a review',
                        style: TextStyle(
                          fontSize: 33,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF241508),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Rating Section
                      _buildRatingSection(),
                      const SizedBox(height: 40),

                      // Headline Input
                      _buildInputField(
                        label: 'Headline',
                        hintText: 'sanusimot@gmail.com',
                        isEmailField: true,
                      ),
                      const SizedBox(height: 32),

                      // Description Input
                      _buildInputField(
                        label: 'Description',
                        hintText: 'Share details of your experience',
                        isDescription: true,
                      ),

                      // Character requirement text
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '100 characters required',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Campton',
                              color: const Color(0xFF595F63).withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 100),
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

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating label
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            color: Color(0xFF3C4042),
          ),
        ),
        const SizedBox(height: 16),

        // Star rating
        Row(
          children: [
            for (int i = 0; i < 5; i++) ...[
              Container(
                width: 32,
                height: 32,
                margin: EdgeInsets.only(right: i < 4 ? 12 : 0),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEDEDE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star_border_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    bool isEmailField = false,
    bool isDescription = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            color: const Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),

        // Input container
        Container(
          height: isDescription ? 111 : 49,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (isEmailField)
                  const Icon(
                    Icons.email_outlined,
                    color: Color(0xFFCCCCCC),
                    size: 20,
                  ),
                if (isEmailField) const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        color: const Color(0xFFCCCCCC),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: isDescription ? 4 : 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
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
            // Submit review action
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            alignment: Alignment.center,
            child: const Text(
              'Submit Review',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
