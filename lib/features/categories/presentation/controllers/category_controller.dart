import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/category_repository_impl.dart';
import '../../domain/category_items.dart';
import '../../domain/category_node.dart';

final categoriesByTypeProvider = FutureProvider.family<List<CategoryNode>, String>((ref, type) async {
  return ref.watch(categoryRepositoryProvider).getCategories(type: type);
});

final categoryChildrenProvider = FutureProvider.family<List<CategoryNode>, int>((ref, id) async {
  return ref.watch(categoryRepositoryProvider).getChildren(id);
});

@immutable
class CategoryItemsState {
  const CategoryItemsState({
    required this.category,
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
  });

  final CategoryNode category;
  final List<CategoryItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => currentPage < lastPage;

  CategoryItemsState copyWith({
    CategoryNode? category,
    List<CategoryItem>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
  }) {
    return CategoryItemsState(
      category: category ?? this.category,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

typedef CategoryItemsArgs = ({String type, String slug});

final categoryItemsProvider = AsyncNotifierProvider.family<CategoryItemsController, CategoryItemsState, CategoryItemsArgs>(
  CategoryItemsController.new,
);

class CategoryItemsController extends AsyncNotifier<CategoryItemsState> {
  CategoryItemsController(this._args);

  final CategoryItemsArgs _args;

  @override
  Future<CategoryItemsState> build() async {
    final res = await ref.watch(categoryRepositoryProvider).getItems(type: _args.type, slug: _args.slug, page: 1);
    return CategoryItemsState(
      category: res.category,
      items: res.items,
      currentPage: res.currentPage,
      lastPage: res.lastPage,
      total: res.total,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    if (current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final res = await ref.read(categoryRepositoryProvider).getItems(type: _args.type, slug: _args.slug, page: nextPage);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...res.items],
          currentPage: res.currentPage,
          lastPage: res.lastPage,
          total: res.total,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      // Keep previous list, stop the loading indicator.
      state = AsyncData(current.copyWith(isLoadingMore: false));
      // ignore: avoid_print
      debugPrint('CategoryItemsController.loadMore error: $e\n$st');
    }
  }
}
