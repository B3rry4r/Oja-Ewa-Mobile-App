// write_review_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';

class WriteReviewScreen extends StatelessWidget {
  const WriteReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppPageScaffold(
      title: 'Write a review',
      showActions: false,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // Rating Section
          _buildRatingSection(context),
          const SizedBox(height: 40),

          // Headline Input
          _buildInputField(
            context: context,
            label: 'Headline',
            hintText: 'sanusimot@gmail.com',
            isEmailField: true,
          ),
          const SizedBox(height: 32),

          // Description Input
          _buildInputField(
            context: context,
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
                  color: colors.textTertiary.withValues(alpha: 0.8),
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
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating label
        Text(
          'Rating',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
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
                  color: colors.surfaceElevated,
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star_border_rounded,
                  color: colors.accent,
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
    required BuildContext context,
    required String label,
    required String hintText,
    bool isEmailField = false,
    bool isDescription = false,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Input container
        Container(
          height: isDescription ? 111 : 49,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (isEmailField)
                  Icon(
                    Icons.email_outlined,
                    color: colors.textTertiary,
                    size: 20,
                  ),
                if (isEmailField) const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: colors.textTertiary,
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
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111111).withValues(alpha: 0.3),
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
