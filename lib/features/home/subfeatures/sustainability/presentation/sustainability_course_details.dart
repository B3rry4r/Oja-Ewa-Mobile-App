import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/widgets/error_state_widget.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/reviews/presentation/controllers/reviews_controller.dart';
import 'package:ojaewa/features/sustainability_details/presentation/controllers/sustainability_details_controller.dart';

/// Sustainability Course Detail Screen - Shows information about a course/event
class SustainabilityCourseDetailScreen extends ConsumerWidget {
  const SustainabilityCourseDetailScreen({
    super.key,
    required this.initiativeId,
  });

  final int initiativeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(sustainabilityDetailsProvider(initiativeId));

    return detailsAsync.when(
      loading: () => const LoadingStateWidget(),
      error: (e, _) => ErrorStateWidget(
        message: 'Failed to load initiative details',
        onRetry: () =>
            ref.invalidate(sustainabilityDetailsProvider(initiativeId)),
      ),
      data: (initiative) => _buildContent(context, ref, initiative),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SustainabilityDetails initiative,
  ) {
    final colors = context.appColors;
    final title = initiative.title;
    final description = initiative.description ?? '';
    final category = initiative.category ?? '';
    final status = initiative.status ?? '';
    final progress = initiative.progressPercentage?.toInt() ?? 0;
    final imageUrl = initiative.imageUrl;

    return AppPageScaffold(
      bottomBar: _buildBottomActionCard(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseHeader(context, title, imageUrl),
            const SizedBox(height: 20),
            _buildDescriptionSection(context, description),
            const SizedBox(height: 16),
            _buildEventDetailsSection(context, category, status, progress),
            const SizedBox(height: 16),
            _buildReviewsSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(
    BuildContext context,
    String title,
    String? imageUrl,
  ) {
    final colors = context.appColors;
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
            const AppImagePlaceholder(width: 168, height: 198, borderRadius: 8),

          const SizedBox(width: 7),

          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
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

  Widget _buildDescriptionSection(BuildContext context, String description) {
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
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
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

  Widget _buildEventDetailsSection(
    BuildContext context,
    String category,
    String status,
    int progress,
  ) {
    final colors = context.appColors;
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
            'Initiative Details',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Category
          _buildEventDetailRow(
            context: context,
            icon: Icons.category_outlined,
            label: 'Category',
            value: displayCategory,
          ),

          const SizedBox(height: 12),

          // Status
          _buildEventDetailRow(
            context: context,
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: displayStatus,
          ),

          const SizedBox(height: 12),

          // Progress
          _buildEventDetailRow(
            context: context,
            icon: Icons.trending_up,
            label: 'Progress',
            value: '$progress%',
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.accent),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final reviewsPage = ref
        .watch(reviewsProvider((type: 'initiative', id: initiativeId)))
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
        arguments: {'type': 'initiative', 'id': initiativeId},
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
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
            // Review Header
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
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star, size: 8, color: colors.accent),
                    ),
                  ],
                ),
              ],
            ),

            if (firstReview != null) ...[
              const SizedBox(height: 24),

              // First review from API
              _buildReviewItem(
                context,
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

  Widget _buildReviewItem(
    BuildContext context, {
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
                color: index < rating ? colors.accent : colors.border,
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
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActionCard(BuildContext context) {
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
                  backgroundColor: colors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                  shadowColor: colors.accent.withValues(alpha: 0.3),
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: colors.onAccent,
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
    final colors = context.appColors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Course Information',
          style: TextStyle(
            fontFamily: 'Campton',
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Would you like to enroll in this course or get more details?',
          style: TextStyle(fontFamily: 'Campton', color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Campton',
                color: colors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to enrollment or details screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Enroll Now',
              style: TextStyle(fontFamily: 'Campton', color: colors.onAccent),
            ),
          ),
        ],
      ),
    );
  }
}
