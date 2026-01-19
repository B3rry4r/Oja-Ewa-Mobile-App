import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/widgets/app_header.dart';
import '../../../../core/ui/price_formatter.dart';
import '../../../account/presentation/controllers/profile_controller.dart';
import '../../domain/ai_models.dart';
import '../controllers/ai_personalization_controller.dart';

/// Personalized Recommendations Screen
/// 
/// Shows AI-curated product recommendations based on user's style DNA profile.
class PersonalizedRecommendationsScreen extends ConsumerStatefulWidget {
  const PersonalizedRecommendationsScreen({super.key});

  @override
  ConsumerState<PersonalizedRecommendationsScreen> createState() =>
      _PersonalizedRecommendationsScreenState();
}

class _PersonalizedRecommendationsScreenState
    extends ConsumerState<PersonalizedRecommendationsScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;
    final userId = user?.id.toString() ?? '';

    final profileAsync = ref.watch(styleProfileProvider(userId));
    final recommendationsAsync = ref.watch(personalizedRecommendationsProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFFBF5),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'For You',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              showActions: false,
            ),

            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFDAF40),
                onRefresh: () async {
                  ref.invalidate(personalizedRecommendationsProvider(userId));
                  ref.invalidate(styleProfileProvider(userId));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Style Profile Card
                      profileAsync.when(
                        loading: () => _buildProfileLoading(),
                        error: (e, st) => _buildNoProfile(),
                        data: (profile) => profile != null 
                            ? _buildProfileCard(profile)
                            : _buildNoProfile(),
                      ),

                      const SizedBox(height: 24),

                      // Category Filters
                      _buildCategoryFilters(),

                      const SizedBox(height: 16),

                      // Recommendations
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: recommendationsAsync.when(
                          loading: () => _buildRecommendationsLoading(),
                          error: (e, st) => _buildRecommendationsError(e),
                          data: (recommendations) {
                            final filtered = _selectedCategory == null
                                ? recommendations
                                : recommendations
                                    .where((r) => r.category == _selectedCategory)
                                    .toList();
                            
                            if (filtered.isEmpty) {
                              return _buildEmptyRecommendations();
                            }
                            
                            return _buildRecommendationsGrid(filtered);
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
        ),
      ),
    );
  }

  Widget _buildProfileCard(StyleDnaProfile profile) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDAF40), Color(0xFFFFCC80)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your Style DNA',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.styleDnaQuiz),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.styleProfile,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          if (profile.preferredStyles != null && profile.preferredStyles!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.preferredStyles!.take(4).map((style) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    style,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoProfile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 30,
              color: Color(0xFFFDAF40),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover Your Style DNA',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a quick quiz to get personalized fashion recommendations based on your unique style.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              color: const Color(0xFF241508).withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.styleDnaQuiz),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDAF40),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text(
              'Take Style Quiz',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      (null, 'All'),
      ('textiles', 'Textiles'),
      ('shoes_bags', 'Shoes & Bags'),
      ('afro_beauty_products', 'Beauty'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final (value, label) = categories[index];
          final isSelected = _selectedCategory == value;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = value),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFFDAF40).withOpacity(0.2),
              checkmarkColor: const Color(0xFFFDAF40),
              labelStyle: TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFF777F84),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFDAF40) : const Color(0xFFEEEEEE),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationsLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE57373)),
            const SizedBox(height: 16),
            const Text(
              'Unable to load recommendations',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF241508),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: const Color(0xFF241508).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRecommendations() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: const Color(0xFF241508).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No recommendations yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF241508),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your style quiz to get personalized recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: const Color(0xFF241508).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsGrid(List<PersonalizedRecommendation> recommendations) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return _buildRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(PersonalizedRecommendation recommendation) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/product/${recommendation.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: recommendation.imageUrl != null
                        ? Image.network(
                            recommendation.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_outlined, color: Color(0xFFCCCCCC))),
                          )
                        : const Center(child: Icon(Icons.image_outlined, color: Color(0xFFCCCCCC))),
                  ),
                  // Match Score Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${(recommendation.matchScore * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF241508),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (recommendation.reason != null) ...[
                      Text(
                        recommendation.reason!,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Campton',
                          color: const Color(0xFF241508).withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      formatPrice(recommendation.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFDAF40),
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
}
