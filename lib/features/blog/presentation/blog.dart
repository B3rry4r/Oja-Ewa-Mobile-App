// blog_content_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/router/app_router.dart';
import 'package:ojaewa/app/widgets/app_bottom_nav_bar.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import 'package:ojaewa/core/ui/ui_error_message.dart';

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
    final recent = ref.watch(blogListProvider);
    final favorites = ref.watch(blogFavoritesProvider);

    final list = _showFavorites ? favorites : recent;

    return Scaffold(
      backgroundColor: const Color(0xFF603814),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 104,
              color: const Color(0xFF603814),
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          HeaderIconButton(
                            asset: AppIcons.notification,
                            iconColor: Colors.white,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                          ),
                          const SizedBox(width: 8),
                          HeaderIconButton(
                            asset: AppIcons.bag,
                            iconColor: Colors.white,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.shoppingBag),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, AppBottomNavBar.height),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Blog',
                          style: TextStyle(
                            fontSize: 33,
                            fontFamily: 'Campton',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF241508),
                          ),
                        ),
                        const SizedBox(height: 44),
                        Row(
                          children: [
                            _tabButton(
                              label: 'Recent Posts',
                              active: !_showFavorites,
                              onTap: () => setState(() => _showFavorites = false),
                            ),
                            const SizedBox(width: 8),
                            _tabButton(
                              label: 'Favorite Posts',
                              active: _showFavorites,
                              onTap: () => setState(() => _showFavorites = true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        list.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Color(0xFFFDAF40)),
                              ),
                            ),
                          ),
                          error: (e, st) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text(UiErrorMessage.from(e), textAlign: TextAlign.center)),
                          ),
                          data: (items) {
                            if (items.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(_showFavorites ? 'No favorite posts yet.' : 'No posts found.'),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                for (final post in items) ...[
                                  _BlogPostCard(post: post),
                                  const SizedBox(height: 16),
                                ],
                                const SizedBox(height: 32),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required String label, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFA15E22) : null,
          borderRadius: BorderRadius.circular(8),
          border: active ? null : Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: active ? const Color(0xFFFBFBFB) : const Color(0xFF301C0A),
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

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BlogDetailScreen(blogSlug: post.slug)),
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
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2021),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.createdAt?.toIso8601String().split('T').first ?? '',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF777F84),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
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
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFA15E22)),
          ),
        ],
      ),
    );
  }
}
