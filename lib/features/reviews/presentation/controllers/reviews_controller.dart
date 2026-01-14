import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reviews_repository_impl.dart';
import '../../domain/review.dart';

typedef ReviewsArgs = ({String type, int id});

final reviewsProvider = FutureProvider.family<ReviewsPage, ReviewsArgs>((ref, args) async {
  return ref.watch(reviewsRepositoryProvider).getReviews(type: args.type, id: args.id);
});

class ReviewSubmitController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> submit({
    required ReviewsArgs args,
    required int rating,
    required String headline,
    required String body,
  }) async {
    state = const AsyncLoading();
    try {
      // Backend expects reviewable_type as FQN.
      final reviewableType = switch (args.type) {
        'product' => 'App\\Models\\Product',
        'order' => 'App\\Models\\Order',
        _ => 'App\\Models\\Product',
      };

      await ref.read(reviewsRepositoryProvider).createReview(
            reviewableId: args.id,
            reviewableType: reviewableType,
            rating: rating,
            headline: headline,
            body: body,
          );

      ref.invalidate(reviewsProvider(args));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final reviewSubmitProvider = AsyncNotifierProvider<ReviewSubmitController, void>(ReviewSubmitController.new);
