import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/error_state_widget.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/business_details/presentation/controllers/business_details_controller.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';

/// Music Artist Profile Screen - Shows detailed information about a music artist
class MusicArtistProfileScreen extends ConsumerWidget {
  const MusicArtistProfileScreen({super.key, required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(businessDetailsProvider(businessId));
    return detailsAsync.when(
      loading: () => const LoadingStateWidget(),
      error: (e, _) => ErrorStateWidget(
        message: 'Failed to load artist details',
        onRetry: () => ref.invalidate(businessDetailsProvider(businessId)),
      ),
      data: (business) => _buildContent(context, ref, business),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, BusinessDetails business) {
    final artistName = business.businessName;
    final biography = business.businessDescription ?? '';
    final email = business.businessEmail ?? '';
    final phone = business.businessPhone ?? '';
    final location = business.fullAddress;
    final instagram = business.instagram ?? '';
    final facebook = business.facebook ?? '';
    final youtube = business.youtube;
    final spotify = business.spotify;
    final imageUrl = business.imageUrl;

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
                  _buildArtistHeader(artistName, imageUrl),

                  const SizedBox(height: 20),

                  // Biography Section
                  _buildBiographySection(biography),

                  const SizedBox(height: 16),

                  // Contact Details Section
                  _buildContactSection(email, phone, location),

                  const SizedBox(height: 16),

                  // Social Links Section (YouTube & Spotify for music, plus Instagram & Facebook)
                  _buildSocialLinksSection(instagram, facebook, youtube, spotify),

                  const SizedBox(height: 16),

                  // Reviews Section
                  _buildReviewsSection(context, ref),

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
            _buildBottomContactCard(context, phone),

          ],
        ),
      ),
    );
  }

  Widget _buildArtistHeader(String artistName, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist Image
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 168,
                height: 198,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const AppImagePlaceholder(width: 168, height: 198, borderRadius: 8),
              ),
            )
          else
            const AppImagePlaceholder(width: 168, height: 198, borderRadius: 8),

          const SizedBox(width: 7),

          // Artist Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistName,
                  style: const TextStyle(
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

  Widget _buildBiographySection(String biography) {
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
            'Biography',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            biography,
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

  Widget _buildContactSection(String email, String phone, String location) {
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
            content: location,
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
            content: phone,
          ),

          const SizedBox(height: 20),

          // Email
          _buildContactItem(
            icon: Icons.email,
            title: 'Email Address',
            content: email,
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
          child: Icon(icon, size: 18, color: Colors.white),
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

  Widget _buildSocialLinksSection(String instagram, String facebook, String? youtube, String? spotify) {
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
            'Social Links',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2021),
            ),
          ),

          const SizedBox(height: 20),

          // YouTube (Music-specific)
          if (youtube != null && youtube.isNotEmpty) ...[
            _buildSocialLinkItem(
              icon: Icons.play_circle_outline,
              platform: 'YouTube',
              handle: youtube,
              onTap: () => _launchUrl(youtube),
            ),
            const SizedBox(height: 16),
          ],

          // Spotify (Music-specific)
          if (spotify != null && spotify.isNotEmpty) ...[
            _buildSocialLinkItem(
              icon: Icons.music_note_outlined,
              platform: 'Spotify',
              handle: spotify,
              onTap: () => _launchUrl(spotify),
            ),
            const SizedBox(height: 16),
          ],

          // Instagram
          _buildSocialLinkItem(
            icon: Icons.camera_alt_outlined,
            platform: 'Instagram',
            handle: instagram,
            onTap: () => _launchUrl('https://instagram.com/${instagram.replaceAll('@', '')}'),
          ),

          const SizedBox(height: 16),

          // Facebook
          _buildSocialLinkItem(
            icon: Icons.facebook_outlined,
            platform: 'Facebook',
            handle: facebook,
            onTap: () => _launchUrl('https://facebook.com/$facebook'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSocialLinkItem({
    required IconData icon,
    required String platform,
    required String handle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
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

          const SizedBox(width: 12),

          // Platform and handle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E2021),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  handle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA15E22),
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Color(0xFF777F84),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, WidgetRef ref) {
    final reviewsPage = ref.watch(reviewsProvider((type: 'business', id: businessId))).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );

    final reviewCount = reviewsPage?.total ?? 0;
    final avgRating = reviewsPage?.entity.avgRating?.toStringAsFixed(1) ?? '0.0';
    final firstReview = (reviewsPage?.items.isNotEmpty ?? false) ? reviewsPage!.items.first : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.reviews,
        arguments: {'type': 'business', 'id': businessId},
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
                Text(
                  'Reviews ($reviewCount)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2021),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Text(
                      avgRating,
                      style: const TextStyle(
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

            if (firstReview != null) ...[
              const SizedBox(height: 24),

              // First review from API
              _buildReviewItem(
                name: firstReview.user?.displayName ?? '',
                date: firstReview.createdAt != null ? _formatDate(firstReview.createdAt!) : '',
                rating: firstReview.rating ?? 0,
                title: firstReview.headline ?? '',
                review: firstReview.body ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '$m ${dt.day}, ${dt.year}';
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

        if (title.isNotEmpty) ...[
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
        ],

        if (review.isNotEmpty) ...[
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
      ],
    );
  }

  Widget _buildBottomContactCard(BuildContext context, String phone) {
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
                onPressed: () => _makePhoneCall(phone),
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
                    Icon(Icons.phone, size: 20, color: Color(0xFFFDAF40)),
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
                onPressed: () => _openWhatsApp(phone),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Clean phone number and ensure it has country code
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // If Nigerian number without country code, add it
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '234${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('234') && cleanNumber.length == 10) {
      cleanNumber = '234$cleanNumber';
    }
    final uri = Uri.parse('https://wa.me/$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

}
