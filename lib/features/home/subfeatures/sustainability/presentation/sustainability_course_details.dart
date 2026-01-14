import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/product_detail/presentation/reviews.dart';
import 'package:ojaewa/features/sustainability_details/presentation/controllers/sustainability_details_controller.dart';

/// Sustainability Course Detail Screen - Shows information about a course/event
class SustainabilityCourseDetailScreen extends ConsumerWidget {
  const SustainabilityCourseDetailScreen({super.key, required this.initiativeId});

  final int initiativeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(sustainabilityDetailsProvider(initiativeId));

    return detailsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFFF8F1),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFFFF8F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF8F1),
          foregroundColor: const Color(0xFF241508),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load initiative'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sustainabilityDetailsProvider(initiativeId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (initiative) => _buildContent(context, initiative),
    );
  }

  Widget _buildContent(BuildContext context, SustainabilityDetails initiative) {
    final title = initiative.title;
    final description = initiative.description ?? 'No description available';
    final category = initiative.category ?? 'General';
    final status = initiative.status ?? 'Active';
    final progress = initiative.progressPercentage?.toInt() ?? 0;
    final imageUrl = initiative.imageUrl;

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
                  const SizedBox(height: 104), // Space for standard header
                  
                  // Course Header with Image
                  _buildCourseHeader(title, imageUrl),
                  
                  const SizedBox(height: 20),
                  
                  // Description Section
                  _buildDescriptionSection(description),
                  
                  const SizedBox(height: 16),
                  
                  // Event Details Section
                  _buildEventDetailsSection(category, status, progress),
                  
                  const SizedBox(height: 16),
                  
                  // Reviews Section
                  _buildReviewsSection(context),
                  
                  const SizedBox(height: 180), // Space for bottom card and button
                ],
              ),
            ),
            
            // Fixed Top App Bar
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            
            // Fixed Bottom Action Card
            _buildBottomActionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(String title, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 168,
                height: 198,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const AppImagePlaceholder(
                  width: 168,
                  height: 198,
                  borderRadius: 8,
                ),
              ),
            )
          else
            const AppImagePlaceholder(
              width: 168,
              height: 198,
              borderRadius: 8,
            ),
          
          const SizedBox(width: 7),
          
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
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

  Widget _buildDescriptionSection(String description) {
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
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
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

  Widget _buildEventDetailsSection(String category, String status, int progress) {
    // Capitalize first letter of category
    final displayCategory = category.isNotEmpty 
        ? '${category[0].toUpperCase()}${category.substring(1)}'
        : 'General';
    final displayStatus = status.isNotEmpty 
        ? '${status[0].toUpperCase()}${status.substring(1)}'
        : 'Active';

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
            'Initiative Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Category
          _buildEventDetailRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: displayCategory,
          ),
          
          const SizedBox(height: 12),
          
          // Status
          _buildEventDetailRow(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: displayStatus,
          ),
          
          const SizedBox(height: 12),
          
          // Progress
          _buildEventDetailRow(
            icon: Icons.trending_up,
            label: 'Progress',
            value: '$progress%',
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFA15E22),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF777F84),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E2021),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReviewsScreen()),
      ),
      child: Container(
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
    ));
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