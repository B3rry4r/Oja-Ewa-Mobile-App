import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/network/dio_clients.dart';

import '../../data/blog_favorites_api.dart';
import '../../domain/blog_post.dart';

final blogFavoritesApiProvider = Provider<BlogFavoritesApi>((ref) {
  return BlogFavoritesApi(ref.read(laravelDioProvider));
});

final blogFavoritesProvider = FutureProvider<List<BlogPost>>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return const [];
  
  return ref.read(blogFavoritesApiProvider).getFavorites();
});

/// Optimistic set of favorited blog IDs - updated immediately on user action
class OptimisticFavoritesNotifier extends Notifier<Set<int>> {
  bool _initialized = false;

  @override
  Set<int> build() {
    // Listen to server data only for initial load
    ref.listen(blogFavoritesProvider, (_, next) {
      if (!_initialized) {
        final data = next.asData?.value;
        if (data != null) {
          state = data.map((b) => b.id).toSet();
          _initialized = true;
        }
      }
    });
    // Initialize with current data if available
    final initialData = ref.read(blogFavoritesProvider).asData?.value;
    if (initialData != null) {
      _initialized = true;
      return initialData.map((b) => b.id).toSet();
    }
    return {};
  }

  void addFavorite(int blogId) {
    state = {...state, blogId};
    _initialized = true;
  }

  void removeFavorite(int blogId) {
    state = state.where((id) => id != blogId).toSet();
    _initialized = true;
  }

  void setFavorites(Set<int> ids) {
    state = ids;
    _initialized = true;
  }
}

final optimisticFavoritesProvider = NotifierProvider<OptimisticFavoritesNotifier, Set<int>>(
  OptimisticFavoritesNotifier.new,
);

class BlogFavoritesActions extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> add(int blogId) async {
    // Save previous state for rollback
    final previousFavorites = ref.read(optimisticFavoritesProvider);
    
    // Optimistically add
    ref.read(optimisticFavoritesProvider.notifier).addFavorite(blogId);

    try {
      await ref.read(blogFavoritesApiProvider).addFavorite(blogId);
      // Success - optimistic state is the truth
    } catch (e, st) {
      // Revert on failure
      ref.read(optimisticFavoritesProvider.notifier).setFavorites(previousFavorites);
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> remove(int blogId) async {
    // Save previous state for rollback
    final previousFavorites = ref.read(optimisticFavoritesProvider);
    
    // Optimistically remove
    ref.read(optimisticFavoritesProvider.notifier).removeFavorite(blogId);

    try {
      await ref.read(blogFavoritesApiProvider).removeFavorite(blogId);
      // Success - optimistic state is the truth
    } catch (e, st) {
      // Revert on failure
      ref.read(optimisticFavoritesProvider.notifier).setFavorites(previousFavorites);
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final blogFavoritesActionsProvider = AsyncNotifierProvider<BlogFavoritesActions, void>(BlogFavoritesActions.new);

/// Convenience: check if a blog id is favorited.
/// Uses optimistic state for immediate, deterministic updates.
final isBlogFavoritedProvider = Provider.family<bool, int>((ref, blogId) {
  final favorites = ref.watch(optimisticFavoritesProvider);
  return favorites.contains(blogId);
});
