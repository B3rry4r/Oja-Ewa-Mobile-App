// blog_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';
import 'package:ojaewa/features/blog/presentation/controllers/blog_controller.dart';
import 'package:ojaewa/features/blog/presentation/controllers/blog_favorites_controller.dart';

class BlogDetailScreen extends ConsumerWidget {
  const BlogDetailScreen({super.key, required this.blogSlug});

  final String blogSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blog = ref.watch(blogBySlugProvider(blogSlug));
    final colors = context.appColors;

    return blog.when(
      loading: () => const AppPageScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => AppPageScaffold(
        child: Center(child: Text('Failed to load blog.\n$e')),
      ),
      data: (post) {
        final dateText =
            post.createdAt?.toIso8601String().split('T').first ?? '';
        final isFav = ref.watch(isBlogFavoritedProvider(post.id));

        return AppPageScaffold(
          scrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () async {
                      final token = ref.read(accessTokenProvider);
                      if (token == null || token.isEmpty) {
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
                          AppSnackbars.showSuccess(
                            context,
                            'Removed from favorites',
                          );
                        } else {
                          await ref
                              .read(blogFavoritesActionsProvider.notifier)
                              .add(post.id);
                          if (!context.mounted) return;
                          AppSnackbars.showSuccess(
                            context,
                            'Added to favorites',
                          );
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
                ),
              ),
              Container(
                color: colors.surfaceSecondary,
                padding: const EdgeInsets.only(left: 18, right: 16, bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 165,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                          ? Image.network(
                              post.imageUrl!,
                              fit: BoxFit.cover,
                              width: 165,
                              height: 100,
                              errorBuilder: (_, _, _) =>
                                  const AppImagePlaceholder(
                                    width: 150,
                                    height: 100,
                                    borderRadius: 8,
                                  ),
                            )
                          : const AppImagePlaceholder(
                              width: 150,
                              height: 100,
                              borderRadius: 8,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateText,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Campton',
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildArticleContent(context, post.content),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleContent(BuildContext context, String content) {
    return Text(
      content.isEmpty ? 'No content' : content,
      style: TextStyle(
        fontSize: 16,
        fontFamily: 'Campton',
        fontWeight: FontWeight.w400,
        color: context.appColors.textPrimary,
        height: 1.6,
      ),
    );
  }
}
