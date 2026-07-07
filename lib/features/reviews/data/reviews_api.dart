import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/review.dart';

class ReviewsApi {
  ReviewsApi(this._dio);

  final Dio _dio;

  Future<ReviewsPage> getReviews({required String type, required int id}) async {
    try {
      // Product pages are guest-browsable, so read product reviews from the
      // public endpoint (product-only, no auth required). Other entity types
      // (e.g. business) have no public read endpoint and stay on the authed one.
      final path = type == 'product' ? '/api/reviews/public/$type/$id' : '/api/reviews/$type/$id';
      final res = await _dio.get(path);
      final data = res.data;
      if (data is! Map<String, dynamic>) throw const FormatException('Unexpected response');
      return ReviewsPage.fromJson(data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> createReview({
    required int reviewableId,
    required String reviewableType,
    required int rating,
    required String headline,
    required String body,
  }) async {
    try {
      await _dio.post(
        '/api/reviews',
        data: {
          'reviewable_id': reviewableId,
          'reviewable_type': reviewableType,
          'rating': rating,
          'headline': headline,
          'body': body,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
