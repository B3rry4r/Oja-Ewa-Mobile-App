// blog_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        child: blog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Failed to load blog.\n$e')),
          data: (post) {
            final dateText = post.createdAt?.toIso8601String().split('T').first ?? '';

            final isFav = ref.watch(isBlogFavoritedProvider(post.id));

            return Column(
              children: [
                const AppHeader(iconColor: Colors.white),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        try {
                          if (isFav) {
                            await ref.read(blogFavoritesActionsProvider.notifier).remove(post.id);
                            if (!context.mounted) return;
                            AppSnackbars.showSuccess(context, 'Removed from favorites');
                          } else {
                            await ref.read(blogFavoritesActionsProvider.notifier).add(post.id);
                            if (!context.mounted) return;
                            AppSnackbars.showSuccess(context, 'Added to favorites');
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          AppSnackbars.showError(context, UiErrorMessage.from(e));
                        }
                      },
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFDAF40)),
                    ),
                  ),
                ),

                // Header section
                Container(
                  color: const Color(0xFF603814),
                  padding: const EdgeInsets.only(left: 18, right: 16, bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image card
                      Container(
                        width: 165,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                            ? Image.network(
                                post.imageUrl!,
                                fit: BoxFit.cover,
                                width: 165,
                                height: 100,
                                errorBuilder: (_, __, ___) => const AppImagePlaceholder(
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
                                color: const Color(0xFFF4F4F4).withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Campton',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFF8F1),
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

                // Main content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8F1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildArticleContent(post.content),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticleContent(String content) {
    return Text(
      content.isEmpty ? 'No content' : content,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'Campton',
        fontWeight: FontWeight.w400,
        color: Colors.black,
        height: 1.6,
      ),
    );
  }
}
