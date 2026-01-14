import 'package:dio/dio.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../domain/review.dart';

class ReviewsApi {
  ReviewsApi(this._dio);

  final Dio _dio;

  Future<ReviewsPage> getReviews({required String type, required int id}) async {
    try {
      final res = await _dio.get('/api/reviews/$type/$id');
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
