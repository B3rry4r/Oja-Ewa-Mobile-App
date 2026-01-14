import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/review.dart';
import 'reviews_api.dart';

class ReviewsRepository {
  ReviewsRepository(this._api);

  final ReviewsApi _api;

  Future<ReviewsPage> getReviews({required String type, required int id}) => _api.getReviews(type: type, id: id);

  Future<void> createReview({
    required int reviewableId,
    required String reviewableType,
    required int rating,
    required String headline,
    required String body,
  }) {
    return _api.createReview(
      reviewableId: reviewableId,
      reviewableType: reviewableType,
      rating: rating,
      headline: headline,
      body: body,
    );
  }
}

final reviewsApiProvider = Provider<ReviewsApi>((ref) {
  return ReviewsApi(ref.watch(laravelDioProvider));
});

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.watch(reviewsApiProvider));
});
