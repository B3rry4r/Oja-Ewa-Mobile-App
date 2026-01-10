import 'package:flutter/material.dart';

/// Sustainability Course Detail Screen - Shows information about a course/event
class SustainabilityCourseDetailScreen extends StatelessWidget {
  const SustainabilityCourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80), // Space for top bar
                  
                  // Course Header with Image
                  _buildCourseHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Description Section
                  _buildDescriptionSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Speakers Section
                  _buildSpeakersSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Reviews Section
                  _buildReviewsSection(),
                  
                  const SizedBox(height: 180), // Space for bottom card and button
                ],
              ),
            ),
            
            // Fixed Top App Bar
            _buildTopAppBar(context),
            
            // Fixed Bottom Action Card
            _buildBottomActionCard(context),
            
            // Floating Add Review Button
            _buildFloatingReviewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFFFFF8F1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            _buildIconButton(Icons.arrow_back_ios_new, () {
              Navigator.of(context).pop();
            }),
            
            const Spacer(),
            
            // Search Button
            _buildIconButton(Icons.search, () {
              // Handle search
            }),
            
            const SizedBox(width: 4),
            
            // Cart Button
            _buildIconButton(Icons.shopping_cart_outlined, () {
              // Handle cart
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: const Color(0xFF603814)),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image
          Container(
            width: 168,
            height: 198,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            // Placeholder for course image
          ),
          
          const SizedBox(width: 7),
          
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Managing\nFinances',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF241508),
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Rating
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFDB80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 8,
                        color: Color(0xFFFDAF40),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF241508),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '(8)',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF777F84),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'We are Spa, Beauty and wellness company offering, Spa pampering services, skincare solutions and haircare services',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E2021),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Speakers',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Speaker 1
          const Text(
            'Lennox Emanuel \n(Strategist)',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E2021),
              height: 1.25,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Speaker 2
          const Text(
            'Lennox Emanuel \n(Strategist)',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF1E2021),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDEDEDE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reviews (4)',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2021),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Text(
                    '4.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2021),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDB80),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 8,
                      color: Color(0xFFFDAF40),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Individual Review
          _buildReviewItem(
            name: 'Lennox Len',
            date: 'Aug 19, 2023',
            rating: 5,
            title: 'So good',
            review: 'Good customer service, I was at the Spa some times back, the receptionist is ok and their agents are so good at what they do. Will use them again',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required int rating,
    required String title,
    required String review,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviewer name and date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFF3C4042),
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: Color(0xFFB1B1B1),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Star rating
        Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 12,
                color: const Color(0xFFFFDB80),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Review title
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E2021),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Review text
        Text(
          review,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E2021),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionCard(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF603814),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 38), // Extra padding at top
            
            // Learn More Button
            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton(
                onPressed: () {
                  // Handle learn more action
                  _showLearnMoreDialog(context);
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
                  'Learn More',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFBF5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingReviewButton() {
    return Positioned(
      bottom: 130,
      right: 22,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            size: 20,
            color: Color(0xFF603814),
          ),
          padding: EdgeInsets.zero,
          onPressed: () {
            // Handle add review
          },
        ),
      ),
    );
  }

  void _showLearnMoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Course Information',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Would you like to enroll in this course or get more details?',
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
              // Navigate to enrollment or details screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Enroll Now',
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