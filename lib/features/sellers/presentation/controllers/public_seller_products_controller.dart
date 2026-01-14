import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/public_seller_repository_impl.dart';
import '../../../product/presentation/controllers/product_details_controller.dart';

class SellerProductsState {
  const SellerProductsState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<ProductDetails> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  SellerProductsState copyWith({
    List<ProductDetails>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SellerProductsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

typedef SellerProductsArgs = ({int sellerId});

class PublicSellerProductsController extends AsyncNotifier<SellerProductsState> {
  PublicSellerProductsController(this._args);

  final SellerProductsArgs _args;

  @override
  FutureOr<SellerProductsState> build() async {
    final items = await ref.watch(publicSellerRepositoryProvider).getSellerProducts(
          sellerId: _args.sellerId,
          page: 1,
          perPage: 10,
        );
    // If backend doesn't provide last_page info here, we infer hasMore by page size.
    final hasMore = items.length >= 10;
    return SellerProductsState(items: items, page: 1, hasMore: hasMore);
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    if (!current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;
    try {
      final next = await ref.read(publicSellerRepositoryProvider).getSellerProducts(
            sellerId: _args.sellerId,
            page: nextPage,
            perPage: 10,
          );

      final hasMore = next.length >= 10;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next],
          page: nextPage,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final publicSellerProductsPagedProvider = AsyncNotifierProvider.family<PublicSellerProductsController, SellerProductsState, SellerProductsArgs>(
  PublicSellerProductsController.new,
);
