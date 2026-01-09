// blog_detail_screen.dart
import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              iconColor: Colors.white,
            ),

            // Header section - Image and Text in a Row
            Container(
              color: const Color(0xFF603814),
              padding: const EdgeInsets.only(left: 18, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image card
                  Container(
                    width: 150,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Placeholder(),
                  ),

                  // Spacing between image and text
                  const SizedBox(width: 8), // 191 - 165 - 18 = 8

                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        const SizedBox(height: 17), // 117 - 100 = 17
                        Text(
                          '18th March, 2023',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFF4F4F4).withOpacity(0.8),
                          ),
                        ),

                        // Title
                        const SizedBox(height: 18), // 147 - 117 - 12 = 18
                        Text(
                          'Fashion in current age: Role of parents in fashions',
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFF8F1),
                            height: 1.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
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
                        const SizedBox(height: 20),
                        _buildArticleContent(),
                        const SizedBox(height: 40),
                        const Text(
                          'Related Posts',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildRelatedPosts(),
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

  Widget _buildArticleContent() {
    const articleText = '''
Fendi’s signature Baguette bags come in different sizes — all in the jeweler’s signature Tiffany Blue color. The accessories also feature a variety of fabrics and finishes like croc-effect leathers, silk, and even a special one-of-a-kind Baguette in sterling silver. (The latter was made by Tiffany & Co. artisans over a period of four months and are engraved with lilies and roses — the national flowers of Italy and New York State, respectively.)

Fendi’s signature Baguette bags come in different sizes — all in the jeweler’s signature Tiffany Blue color. The accessories also feature a variety of fabrics and finishes like croc-effect leathers, silk, and even a special one-of-a-kind Baguette in sterling silver.
    ''';
    
    return Text(
      articleText,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'Campton',
        fontWeight: FontWeight.w400,
        color: Colors.black,
        height: 1.6,
      ),
    );
  }

  Widget _buildRelatedPosts() {
    return Column(
      children: [
        _buildRelatedPostCard(),
        const SizedBox(height: 16),
        _buildRelatedPostCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRelatedPostCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 59,
            height: 69,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fashion in current age: Role of parents in fashion',
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
                  '18th March, 2023',
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
    );
  }
}