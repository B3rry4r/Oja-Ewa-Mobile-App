import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/product_detail/presentation/reviews.dart';

/// Music Artist Profile Screen - Shows detailed information about a music artist
class MusicArtistProfileScreen extends StatelessWidget {
  const MusicArtistProfileScreen({super.key});

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
                  const SizedBox(height: 104), // Space for standard header
                  
                  // Artist Header with Image
                  _buildArtistHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Biography Section
                  _buildBiographySection(),
                  
                  const SizedBox(height: 16),
                  
                  // Contact Details Section
                  _buildContactSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Albums Section
                  _buildAlbumsSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Reviews Section
                  _buildReviewsSection(context),
                  
                  const SizedBox(height: 180), // Space for bottom card
                ],
              ),
            ),
            
            // Fixed Top App Bar
            const AppHeader(
              backgroundColor: Color(0xFFFFF8F1),
              iconColor: Color(0xFF241508),
            ),
            
            // Fixed Bottom Contact Card
            _buildBottomContactCard(context),
            
            // Floating Add Review Button
            _buildFloatingReviewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist Image
          const AppImagePlaceholder(
            width: 168,
            height: 198,
            borderRadius: 8,
          ),
          
          const SizedBox(width: 7),
          
          // Artist Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rasheed\nKelani',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF241508),
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 12),
                
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

  Widget _buildBiographySection() {
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
            'Biography',
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

  Widget _buildContactSection() {
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
            'Contact Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Address',
            content: '345 Ralph Shodeinde Street, Central Area Abuja, 9001',
            actionText: 'Get Direction',
            onActionTap: () {
              // Open maps
            },
          ),
          
          const SizedBox(height: 20),
          
          // Phone
          _buildContactItem(
            icon: Icons.phone,
            title: 'Phone Number',
            content: '+234 8068 2833 23\n+234 9124 2344 21',
          ),
          
          const SizedBox(height: 20),
          
          // Email
          _buildContactItem(
            icon: Icons.email,
            title: 'Email Address',
            content: 'rasheedkelani@gmail.com',
          ),
          
          const SizedBox(height: 20),
          
          // Working Hours
          _buildContactItem(
            icon: Icons.access_time,
            title: 'Working hours',
            content: 'Monday to Friday: 9am - 6pm\nSaturday - Sunday: Closed',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF603814),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(width: 8),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              if (actionText != null && onActionTap != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onActionTap,
                  child: Row(
                    children: [
                      Text(
                        actionText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3C4042),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFF3C4042),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumsSection() {
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
            'Albums',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Album List
          _buildAlbumItem(
            title: 'Kelewa',
            streamingLinks: 'Apple Music, Spotify, Youtube',
          ),
          
          const SizedBox(height: 20),
          
          _buildAlbumItem(
            title: 'Baba L\'oke',
            streamingLinks: 'Apple Music, Spotify, Youtube',
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumItem({
    required String title,
    required String streamingLinks,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Album Title with Play Button
        Row(
          children: [
            // Play Button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF603814),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 20,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(width: 8),
            
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E2021),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Streaming Links
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            streamingLinks,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF777F84),
              height: 1.4,
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget _buildBottomContactCard(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF603814),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
        child: Row(
          children: [
            // Call Button
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  // Handle call action
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFDAF40), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.phone,
                      size: 20,
                      color: Color(0xFFFDAF40),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Call',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFDAF40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // WhatsApp Button
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  // Handle WhatsApp action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDAF40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFFFDAF40).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Color(0xFFFFFBF5),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Whatsapp',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFBF5),
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

  Widget _buildFloatingReviewButton() {
    return Positioned(
      bottom: 165,
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

}