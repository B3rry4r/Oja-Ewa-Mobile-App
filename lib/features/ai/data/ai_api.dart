import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/ai_models.dart';

/// AI API Service
/// 
/// Handles all AI-related API calls to the Node.js AI backend.
/// Base URL is configured in AppUrls.aiBaseUrl
class AiApi {
  AiApi(this._dio);

  final Dio _dio;

  // ============================================================
  // CULTURAL CONTEXT AI (Chat)
  // ============================================================

  /// Send a message to the cultural AI assistant
  Future<AiChatMessage> sendChatMessage({
    required String message,
    String? userId,
    String? context,
  }) async {
    final response = await _dio.post('/ai/buyer/chat', data: {
      'message': message,
      if (userId != null) 'userId': userId,
      if (context != null) 'context': context,
    });
    
    final data = response.data as Map<String, dynamic>;
    return AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: data['response'] as String? ?? '',
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: (data['suggestions'] as List<dynamic>?)?.cast<String>(),
      products: (data['products'] as List<dynamic>?)
          ?.map((p) => AiSuggestedProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get chat history for a user
  Future<List<AiChatMessage>> getChatHistory(String userId) async {
    final response = await _dio.get('/ai/buyer/chat/history/$userId');
    
    final data = response.data as Map<String, dynamic>;
    final history = data['history'] as List<dynamic>? ?? [];
    
    return history
        .map((m) => AiChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // SMART PRODUCT DESCRIPTIONS
  // ============================================================

  /// Generate AI product description
  Future<AiProductDescription> generateProductDescription({
    required String name,
    required String style,
    required String tribe,
    required String gender,
    required double price,
    String? materials,
    String? occasion,
    List<String>? colors,
  }) async {
    final response = await _dio.post('/ai/seller/product/description', data: {
      'name': name,
      'style': style,
      'tribe': tribe,
      'gender': gender,
      'price': price,
      if (materials != null) 'materials': materials,
      if (occasion != null) 'occasion': occasion,
      if (colors != null) 'colors': colors,
    });
    
    return AiProductDescription.fromJson(response.data as Map<String, dynamic>);
  }

  /// Generate batch product descriptions (up to 10)
  Future<List<AiProductDescription>> generateBatchDescriptions(
    List<ProductDescriptionRequest> products,
  ) async {
    final response = await _dio.post('/ai/seller/product/description/batch', data: {
      'products': products.map((p) => p.toJson()).toList(),
    });
    
    final data = response.data as Map<String, dynamic>;
    final descriptions = data['descriptions'] as List<dynamic>? ?? [];
    
    return descriptions
        .map((d) => AiProductDescription.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // PERSONALIZATION (Style DNA & Recommendations)
  // ============================================================

  /// Submit style quiz answers
  Future<StyleDnaProfile> submitStyleQuiz({
    required String userId,
    required List<StyleQuizAnswer> answers,
  }) async {
    final response = await _dio.post('/ai/buyer/style-quiz', data: {
      'userId': userId,
      'answers': answers.map((a) => a.toJson()).toList(),
    });
    
    return StyleDnaProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get personalized recommendations for a user
  Future<List<PersonalizedRecommendation>> getRecommendations({
    required String userId,
    int? limit,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (category != null) queryParams['category'] = category;
    
    final response = await _dio.get(
      '/ai/buyer/recommendations/$userId',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    
    final data = response.data as Map<String, dynamic>;
    final recommendations = data['recommendations'] as List<dynamic>? ?? [];
    
    return recommendations
        .map((r) => PersonalizedRecommendation.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Get user's style DNA profile
  Future<StyleDnaProfile?> getStyleProfile(String userId) async {
    try {
      final response = await _dio.get('/ai/buyer/style-profile/$userId');
      return StyleDnaProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Get personal trend forecasting
  Future<TrendData> getPersonalTrends(String userId) async {
    final response = await _dio.get('/ai/buyer/trends/personal/$userId');
    return TrendData.fromJson(response.data as Map<String, dynamic>);
  }

  // ============================================================
  // INVENTORY & TREND PREDICTION (Seller Analytics)
  // ============================================================

  /// Get trending styles for a category
  Future<TrendData> getCategoryTrends(String category) async {
    final response = await _dio.get('/ai/seller/trends/$category');
    return TrendData.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get inventory forecast
  Future<List<InventoryForecast>> getInventoryForecast({
    required String sellerId,
    String? category,
    int? daysAhead,
  }) async {
    final response = await _dio.post('/ai/seller/inventory/forecast', data: {
      'sellerId': sellerId,
      if (category != null) 'category': category,
      if (daysAhead != null) 'daysAhead': daysAhead,
    });
    
    final data = response.data as Map<String, dynamic>;
    final forecasts = data['forecasts'] as List<dynamic>? ?? [];
    
    return forecasts
        .map((f) => InventoryForecast.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  /// Get seller performance comparison
  Future<SellerPerformance> getSellerPerformance(String sellerId) async {
    final response = await _dio.get('/ai/seller/trends/seller/$sellerId');
    return SellerPerformance.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get color trend prediction
  Future<DemandPrediction> getColorTrendPrediction(String category) async {
    final response = await _dio.post('/ai/seller/demand/forecast-color/$category');
    return DemandPrediction.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get size demand prediction
  Future<DemandPrediction> getSizeDemandPrediction(String category) async {
    final response = await _dio.post('/ai/seller/demand/forecast-size/$category');
    return DemandPrediction.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get inventory optimization suggestions
  Future<Map<String, dynamic>> getInventoryOptimization({
    required String sellerId,
    required double budget,
  }) async {
    final response = await _dio.post('/ai/seller/demand/inventory-optimize', data: {
      'sellerId': sellerId,
      'budget': budget,
    });
    
    return response.data as Map<String, dynamic>;
  }

  /// Get customer profile insights (for sellers)
  Future<Map<String, dynamic>> getCustomerProfile(String customerId) async {
    final response = await _dio.get('/ai/seller/customer/profile/$customerId');
    return response.data as Map<String, dynamic>;
  }
}

/// Provider for AI API
final aiApiProvider = Provider<AiApi>((ref) {
  final dio = ref.watch(aiDioProvider);
  return AiApi(dio);
});
