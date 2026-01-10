import 'package:flutter/material.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String selectedFilter = 'All';

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
              showActions: false,
            ),

            // Main content card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Header with title and write review button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reviews (20)',
                            style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF241508),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.reviewSubmission),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: const Text(
                                'Write Review',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Rating summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          // Star icons
                          Row(
                            children: [
                              _buildStarIcon(true),
                              _buildStarIcon(true),
                              _buildStarIcon(true),
                              _buildStarIcon(true),
                              _buildHalfStarIcon(),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Rating number
                          const Text(
                            '4.0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E2021),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Filter chips
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildFilterChip('All', true),
                          const SizedBox(width: 12),
                          _buildFilterChip('5', false, hasIcon: true),
                          const SizedBox(width: 12),
                          _buildFilterChip('4', false, hasIcon: true),
                          const SizedBox(width: 12),
                          _buildFilterChip('4', false, hasIcon: true),
                          const SizedBox(width: 12),
                          _buildFilterChip('2', false, hasIcon: true),
                          const SizedBox(width: 12),
                          _buildFilterChip('1', false, hasIcon: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Sort button
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCCCCCC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_vert,
                                size: 20,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Sort',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reviews list
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: 5,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildReviewCard();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarIcon(bool filled) {
    return Container(
      width: 11,
      height: 11,
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFFFDB80) : const Color(0xFFD7D7D7),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHalfStarIcon() {
    return SizedBox(
      width: 22,
      height: 11,
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDB80),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 11,
            height: 11,
            decoration: const BoxDecoration(
              color: Color(0xFFD7D7D7),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {bool hasIcon = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA15E22) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFA15E22) : const Color(0xFFCCCCCC),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFFFBFBFB) : const Color(0xFF3C4042),
              ),
            ),
            if (hasIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                size: 16,
                color: isSelected ? const Color(0xFFFBFBFB) : const Color(0xFF3C4042),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviewer info and date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lennox Len',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3C4042),
              ),
            ),
            Text(
              'Aug 19, 2023',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Star rating
        Row(
          children: List.generate(5, (index) {
            return const Icon(
              Icons.star,
              size: 11,
              color: Color(0xFFFFDB80),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Review title
        const Text(
          'So good',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E2021),
          ),
        ),

        const SizedBox(height: 8),

        // Review text
        const Text(
          'Good customer service, I was at the Spa some times back, the receptionist is ok and their agents are so goos aat what they do. Will use them again',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E2021),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        // Helpful buttons
        Row(
          children: [
            const Text(
              'Was this review helpful?',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF1E2021),
              ),
            ),
            const Spacer(),
            _buildHelpfulButton('Yes'),
            const SizedBox(width: 8),
            _buildHelpfulButton('No'),
          ],
        ),

        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          color: const Color(0xFFEEEEEE),
        ),
      ],
    );
  }

  Widget _buildHelpfulButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF3C4042),
        ),
      ),
    );
  }
}