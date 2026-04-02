import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/widgets/error_state_widget.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/business_details/presentation/controllers/business_details_controller.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';
import 'package:ojaewa/features/home/subfeatures/schools/presentation/school_registration_form.dart';

/// School Detail Screen - Shows detailed information about a training school/institution
class SchoolDetailScreen extends ConsumerWidget {
  const SchoolDetailScreen({super.key, required this.businessId});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(businessDetailsProvider(businessId));
    return detailsAsync.when(
      loading: () => const LoadingStateWidget(),
      error: (e, _) => ErrorStateWidget(
        message: 'Failed to load school details',
        onRetry: () => ref.invalidate(businessDetailsProvider(businessId)),
      ),
      data: (business) => _buildContent(context, ref, business),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BusinessDetails business,
  ) {
    final colors = context.appColors;
    final schoolName = business.businessName;
    // Use school_biography if available, otherwise fall back to business_description
    final biography =
        business.schoolBiography ?? business.businessDescription ?? '';
    final classes = business.classesOffered; // List<ClassItem>
    final email = business.businessEmail ?? '';
    final phone = business.businessPhone ?? '';
    final location = business.fullAddress;
    final websiteUrl = business.websiteUrl;
    final imageUrl = business.imageUrl;

    return AppPageScaffold(
      bottomBar: _buildBottomRegistrationCard(context, websiteUrl, businessId),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSchoolHeader(context, schoolName, imageUrl),
            const SizedBox(height: 20),
            _buildBiographySection(context, biography),
            const SizedBox(height: 16),
            _buildClassesSection(context, classes),
            const SizedBox(height: 16),
            _buildContactSection(context, email, phone, location),
            const SizedBox(height: 16),
            _buildReviewsSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolHeader(
    BuildContext context,
    String schoolName,
    String? imageUrl,
  ) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School Image
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
            const AppImagePlaceholder(width: 168, height: 198, borderRadius: 8),

          const SizedBox(width: 7),

          // School Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolName,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
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
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star, size: 8, color: colors.accent),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(8)',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: colors.textTertiary,
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

  Widget _buildBiographySection(BuildContext context, String biography) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School Biography',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            biography,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesSection(BuildContext context, List<ClassItem> classes) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classes',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...classes.map(
            (classItem) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      classItem.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (classItem.duration != null &&
                      classItem.duration!.isNotEmpty)
                    Text(
                      classItem.duration!,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: colors.accent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
    BuildContext context,
    String email,
    String phone,
    String location,
  ) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Address
          _buildContactItem(
            context: context,
            icon: Icons.location_on,
            title: 'Address',
            content: location,
          ),

          const SizedBox(height: 20),

          // Phone
          _buildContactItem(
            context: context,
            icon: Icons.phone,
            title: 'Phone Number',
            content: phone,
          ),

          const SizedBox(height: 20),

          // Email
          _buildContactItem(
            context: context,
            icon: Icons.email,
            title: 'Email Address',
            content: email,
          ),

          const SizedBox(height: 20),

          // Working Hours
          _buildContactItem(
            context: context,
            icon: Icons.access_time,
            title: 'Working hours',
            content: 'Monday to Friday: 9am - 6pm\nSaturday - Sunday: Closed',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colors.onAccent),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final reviewsPage = ref
        .watch(reviewsProvider((type: 'business', id: businessId)))
        .maybeWhen(data: (d) => d, orElse: () => null);

    final reviewCount = reviewsPage?.total ?? 0;
    final avgRating =
        reviewsPage?.entity.avgRating?.toStringAsFixed(1) ?? '0.0';
    final firstReview = (reviewsPage?.items.isNotEmpty ?? false)
        ? reviewsPage!.items.first
        : null;

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
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews ($reviewCount)',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          avgRating,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
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

                // Add Review Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 24,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),

            if (firstReview != null) ...[
              const SizedBox(height: 24),

              // First review from API
              _buildReviewItem(
                context: context,
                name: firstReview.user?.displayName ?? '',
                date: firstReview.createdAt != null
                    ? _formatDate(firstReview.createdAt!)
                    : '',
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '$m ${dt.day}, ${dt.year}';
  }

  Widget _buildReviewItem({
    required BuildContext context,
    required String name,
    required String date,
    required int rating,
    required String title,
    required String review,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviewer name and date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
            Text(
              date,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textTertiary,
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
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        ],

        if (review.isNotEmpty) ...[
          const SizedBox(height: 8),

          // Review text
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomRegistrationCard(
    BuildContext context,
    String? websiteUrl,
    int? schoolBusinessId,
  ) {
    final colors = context.appColors;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          border: Border(top: BorderSide(color: colors.border)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Register',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Register via Ojá-Ẹwà and have access to sell or showcase on Ojá-Ẹwà after graduation without payment or Register via the school website without the above benefit',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            // Register via Ojá-Ẹwà Button
            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SchoolRegistrationFormScreen(
                        businessId: schoolBusinessId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                  shadowColor: colors.accent.withValues(alpha: 0.3),
                ),
                child: Text(
                  'Register via Ojá-Ẹwà',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Visit School Button
            SizedBox(
              width: double.infinity,
              height: 57,
              child: OutlinedButton(
                onPressed: websiteUrl != null && websiteUrl.isNotEmpty
                    ? () => _launchWebsite(websiteUrl)
                    : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.accent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  disabledForegroundColor: colors.accent.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Visit School',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: colors.accent,
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

  Future<void> _launchWebsite(String url) async {
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
