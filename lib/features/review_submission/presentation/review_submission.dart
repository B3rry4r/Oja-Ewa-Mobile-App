// review_submission_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class ReviewSubmissionScreen extends StatelessWidget {
  const ReviewSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(
              iconColor: Colors.white,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildContentCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        const Text(
          'Write a review',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            fontSize: 33,
            height: 1.2,
            letterSpacing: -1,
            color: Color(0xFF241508),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Rating section
        const Text(
          'Rating',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            fontSize: 22,
            height: 1.2,
            color: Color(0xFF3C4042),
          ),
        ),
        const SizedBox(height: 12),

        // Star rating
        _buildStarRating(),
        const SizedBox(height: 24),

        // Headline input
        _buildEmailInput(),
        const SizedBox(height: 24),

        // Description input
        _buildDescriptionInput(),
        const SizedBox(height: 8),

        // Character count reminder
        const Text(
          '100 characters required',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            fontSize: 10,
            height: 1.2,
            color: Color(0xFF595F63),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Submit button
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.star_rate_rounded,
            size: 32,
            color: const Color(0xFFDEDEDE),
          ),
        );
      }),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Headline',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.3,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
          ),
          child: const Text(
            'sanusimot@gmail.com',
            style: TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.5,
              color: Color(0xFFCCCCCC),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.3,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share details of your experience',
            hintStyle: const TextStyle(
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.5,
              color: Color(0xFFCCCCCC),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40), // Orange button
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            child: const Text(
              'Submit Review',
              style: TextStyle(
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.2,
                color: Color(0xFFFFFBF5), // Off-white text
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
