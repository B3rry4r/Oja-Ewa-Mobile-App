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

  // App consistent colors
  static const _backgroundColor = Color(0xFFFFFBF5);
  static const _cardColor = Color(0xFFF5E0CE);
  static const _primaryColor = Color(0xFFFDAF40);
  static const _textDark = Color(0xFF241508);
  static const _textSecondary = Color(0xFF777F84);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;
    final userId = user?.id.toString() ?? '';

    final profileAsync = ref.watch(styleProfileProvider(userId));
    final recommendationsAsync = ref.watch(personalizedRecommendationsProvider(userId));

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: _backgroundColor,
              iconColor: _textDark,
              title: const Text(
                'For You',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              showActions: false,
            ),

            Expanded(
              child: RefreshIndicator(
                color: _primaryColor,
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

                      const SizedBox(height: 16),

                      // Category Filters
                      _buildCategoryFilters(),

                      const SizedBox(height: 16),

                      // Recommendations
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: recommendationsAsync.when(
                          loading: () => _buildRecommendationsLoading(),
                          error: (e, st) => _buildRecommendationsError(),
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
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
        ),
      ),
    );
  }

  Widget _buildProfileCard(StyleDnaProfile profile) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your Style DNA',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.styleDnaQuiz),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.preferredStyles!.take(4).map((style) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    style,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      color: Colors.white,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 28,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover Your Style DNA',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a quick quiz to get personalized fashion recommendations based on your unique style.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Campton',
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.styleDnaQuiz),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Take Style Quiz',
                    style: TextStyle(
                      fontSize: 14,
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
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      (null, 'All'),
      ('textiles', 'Textiles'),
      ('shoes_bags', 'Shoes & Bags'),
      ('afro_beauty_products', 'Beauty'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final (value, label) = cat;
          final isSelected = _selectedCategory == value;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = value),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _primaryColor : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : _textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off, size: 40, color: _textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load recommendations',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                final user = ref.read(userProfileProvider).value;
                final userId = user?.id.toString() ?? '';
                ref.invalidate(personalizedRecommendationsProvider(userId));
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 40, color: _textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No recommendations yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your style quiz to get personalized recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: _textSecondary,
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
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/product/${recommendation.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: recommendation.imageUrl != null
                          ? Image.network(
                              recommendation.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFFCCCCCC),
                                  size: 32,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Color(0xFFCCCCCC),
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  // Match Score Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            '${(recommendation.matchScore * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
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
                        color: _textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (recommendation.reason != null) ...[
                      Text(
                        recommendation.reason!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Campton',
                          color: _textSecondary,
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
                        color: _primaryColor,
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
