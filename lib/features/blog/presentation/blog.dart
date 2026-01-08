// blog_content_screen.dart
import 'package:flutter/material.dart';

import 'single_blog.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with buttons - using semantic grouping
            Container(
              height: 104, // Based on content card position
              color: const Color(0xFF603814),
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left button with proper spacing
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _buildIconButton(Icons.menu),
                    ),

                    // Right buttons group
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          _buildIconButton(Icons.search),
                          const SizedBox(width: 8),
                          _buildIconButton(Icons.more_vert),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content card
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Blog title section
                        const SizedBox(height: 16),
                        const Text(
                          'Blog',
                          style: TextStyle(
                            fontSize: 33,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),

                        // Category tabs with visual grouping
                        const SizedBox(height: 44), // Visual spacing
                        Row(
                          children: [
                            // Active tab
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA15E22),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Recent Posts',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFBFBFB),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Inactive tab
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFCCCCCC),
                                ),
                              ),
                              child: const Text(
                                'Favorite Posts',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Campton',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF301C0A),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Posts list with semantic grouping
                        const SizedBox(height: 24),
                        _buildPostList(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable icon button
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

  // Posts list
  Widget _buildPostList(BuildContext context) {
    return Column(
      children: [
        _buildPostCard(
          context,
          title: 'Fashion in current age: Role of parents in fashion',
          date: '18th March, 2023',
        ),
        const SizedBox(height: 16),
        _buildPostCard(
          context,
          title: 'Fashion in current age: Role of parents in fashion',
          date: '18th March, 2023',
        ),
        const SizedBox(height: 32), // Bottom spacing
      ],
    );
  }

  // Individual post card
  Widget _buildPostCard(
    BuildContext context, {
    required String title,
    required String date,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BlogDetailScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 59,
              height: 69,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2021),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF777F84),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
