// blog_content_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';

import '../domain/blog_post.dart';
import 'controllers/blog_controller.dart';
import 'controllers/blog_favorites_controller.dart';
import 'single_blog.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});

  @override
  ConsumerState<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  bool _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(blogRealtimeProvider);
    final favorites = ref.watch(blogFavoritesProvider);

    final list = _showFavorites ? favorites : recent;

    return AppPageScaffold(
      title: 'Blog',
      showBack: false,
      includeBottomNavSpacing: true,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tabButton(
                context: context,
                label: 'Recent Posts',
                active: !_showFavorites,
                onTap: () => setState(() => _showFavorites = false),
              ),
              const SizedBox(width: 8),
              _tabButton(
                context: context,
                label: 'Favorite Posts',
                active: _showFavorites,
                onTap: () {
                  ref.invalidate(blogFavoritesProvider);
                  setState(() => _showFavorites = true);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          list.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  UiErrorMessage.from(e),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return WBEmptyState(
                  illustration: WBEmptyIllustration.noProducts,
                  label: _showFavorites
                      ? context.l10n.blogNoFavorites
                      : context.l10n.blogNoPosts,
                  sub: _showFavorites
                      ? context.l10n.blogNoFavoritesSub
                      : context.l10n.blogNoPostsSub,
                );
              }

              return Column(
                children: [
                  for (final post in items) ...[
                    _BlogPostCard(post: post),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: AppBottomNavBar.height + 16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required BuildContext context,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: active ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? colors.accent : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: active ? colors.onAccent : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _BlogPostCard extends ConsumerWidget {
  const _BlogPostCard({required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isBlogFavoritedProvider(post.id));
    final colors = context.appColors;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlogDetailScreen(blogSlug: post.slug),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 59,
            height: 69,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(5),
            ),
            clipBehavior: Clip.antiAlias,
            child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                ? Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    width: 59,
                    height: 69,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.createdAt?.toIso8601String().split('T').first ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              // Check if user is logged in
              final token = ref.read(accessTokenProvider);
              if (token == null || token.isEmpty) {
                // Navigate to onboarding
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(AppRoutes.onboarding);
                return;
              }

              try {
                if (isFav) {
                  await ref
                      .read(blogFavoritesActionsProvider.notifier)
                      .remove(post.id);
                  if (!context.mounted) return;
                  AppSnackbars.showSuccess(context, 'Removed from favorites');
                } else {
                  await ref
                      .read(blogFavoritesActionsProvider.notifier)
                      .add(post.id);
                  if (!context.mounted) return;
                  AppSnackbars.showSuccess(context, 'Added to favorites');
                }
              } catch (e) {
                if (!context.mounted) return;
                AppSnackbars.showError(context, UiErrorMessage.from(e));
              }
            },
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
