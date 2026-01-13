import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/network/dio_clients.dart';

import '../../data/blog_favorites_api.dart';
import '../../domain/blog_post.dart';

final blogFavoritesApiProvider = Provider<BlogFavoritesApi>((ref) {
  return BlogFavoritesApi(ref.watch(laravelDioProvider));
});

final blogFavoritesProvider = FutureProvider<List<BlogPost>>((ref) async {
  return ref.watch(blogFavoritesApiProvider).getFavorites();
});

class BlogFavoritesActions extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> add(int blogId) async {
    state = const AsyncLoading();
    try {
      await ref.read(blogFavoritesApiProvider).addFavorite(blogId);
      ref.invalidate(blogFavoritesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> remove(int blogId) async {
    state = const AsyncLoading();
    try {
      await ref.read(blogFavoritesApiProvider).removeFavorite(blogId);
      ref.invalidate(blogFavoritesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final blogFavoritesActionsProvider = AsyncNotifierProvider<BlogFavoritesActions, void>(BlogFavoritesActions.new);

/// Convenience: check if a blog id is favorited.
final isBlogFavoritedProvider = Provider.family<bool, int>((ref, blogId) {
  final favs = ref.watch(blogFavoritesProvider);
  return favs.maybeWhen(
    data: (items) => items.any((b) => b.id == blogId),
    orElse: () => false,
  );
});
