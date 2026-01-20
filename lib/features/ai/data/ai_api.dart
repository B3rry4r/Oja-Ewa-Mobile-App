import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  /// Log helper for AI API calls
  void _log(String method, String endpoint, {dynamic data, dynamic response, int? statusCode, dynamic error}) {
    final timestamp = DateTime.now().toIso8601String();
    final fullUrl = '${_dio.options.baseUrl}$endpoint';
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🤖 [AI API] $timestamp');
    debugPrint('📍 $method $fullUrl');
    if (data != null) {
      debugPrint('📤 Request: $data');
    }
    if (statusCode != null) {
      debugPrint('📊 Status: $statusCode');
    }
    if (response != null) {
      // Truncate response if it's too long (e.g., HTML error pages)
      final responseStr = response.toString();
      if (responseStr.length > 500) {
        debugPrint('📥 Response (truncated): ${responseStr.substring(0, 500)}...');
      } else {
        debugPrint('📥 Response: $responseStr');
      }
    }
    if (error != null) {
      debugPrint('❌ Error: $error');
    }
    debugPrint('═══════════════════════════════════════════════════════════');
  }

  /// Safely parse JSON response, throwing clear error if HTML is returned
  Map<String, dynamic> _parseJsonResponse(dynamic responseData) {
    if (responseData is String) {
      if (responseData.contains('<!DOCTYPE') || responseData.contains('<html')) {
        throw Exception(
          'AI API returned HTML instead of JSON. '
          'Please check the AI_BASE_URL configuration. '
          'Current URL: ${_dio.options.baseUrl}'
        );
      }
      throw Exception('AI API returned unexpected string response: ${responseData.substring(0, 100)}...');
    }
    if (responseData is! Map<String, dynamic>) {
      throw Exception('AI API returned unexpected response type: ${responseData.runtimeType}');
    }
    return responseData;
  }

  // ============================================================
  // CULTURAL CONTEXT AI (Chat)
  // ============================================================

  /// Send a message to the cultural AI assistant
  Future<AiChatMessage> sendChatMessage({
    required String message,
    String? userId,
    String? context,
  }) async {
    const endpoint = '/ai/buyer/chat';
    final requestData = {
      'message': message,
      if (userId != null) 'userId': userId,
      if (context != null) 'context': context,
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      
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
    } on DioException catch (e) {
      _log('POST', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get chat history for a user
  Future<List<AiChatMessage>> getChatHistory(String userId) async {
    final endpoint = '/ai/buyer/chat/history/$userId';
    
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      final history = data['history'] as List<dynamic>? ?? [];
      return history
          .map((m) => AiChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
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
    const endpoint = '/ai/seller/product/description';
    final requestData = {
      'name': name,
      'style': style,
      'tribe': tribe,
      'gender': gender,
      'price': price,
      if (materials != null) 'materials': materials,
      if (occasion != null) 'occasion': occasion,
      if (colors != null) 'colors': colors,
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data);
      return AiProductDescription.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Generate batch product descriptions (up to 10)
  Future<List<AiProductDescription>> generateBatchDescriptions(
    List<ProductDescriptionRequest> products,
  ) async {
    const endpoint = '/ai/seller/product/description/batch';
    final requestData = {'products': products.map((p) => p.toJson()).toList()};
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      final data = response.data as Map<String, dynamic>;
      
      _log('POST', endpoint, response: data);
      
      final descriptions = data['descriptions'] as List<dynamic>? ?? [];
      return descriptions
          .map((d) => AiProductDescription.fromJson(d as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  // ============================================================
  // PERSONALIZATION (Style DNA & Recommendations)
  // ============================================================

  /// Submit style quiz answers
  Future<StyleDnaProfile> submitStyleQuiz({
    required String userId,
    required List<StyleQuizAnswer> answers,
  }) async {
    const endpoint = '/ai/buyer/style-quiz';
    final requestData = {
      'userId': userId,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data);
      return StyleDnaProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get personalized recommendations for a user
  Future<List<PersonalizedRecommendation>> getRecommendations({
    required String userId,
    int? limit,
    String? category,
  }) async {
    final endpoint = '/ai/buyer/recommendations/$userId';
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (category != null) queryParams['category'] = category;
    
    _log('GET', endpoint, data: queryParams.isNotEmpty ? queryParams : null);
    
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = response.data;
      
      // Check for HTML response first
      if (data is String) {
        if (data.contains('<!DOCTYPE') || data.contains('<html')) {
          throw Exception(
            'AI API returned HTML instead of JSON. '
            'The endpoint may not exist or the server is misconfigured. '
            'URL: ${_dio.options.baseUrl}$endpoint'
          );
        }
      }
      
      // Handle both direct list response and wrapped response
      List<dynamic> recommendations;
      if (data is List) {
        recommendations = data;
      } else if (data is Map<String, dynamic>) {
        recommendations = data['recommendations'] as List<dynamic>? ?? [];
      } else {
        recommendations = [];
      }
      
      return recommendations
          .map((r) => PersonalizedRecommendation.fromJson(r))
          .toList();
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  /// Get user's style DNA profile
  Future<StyleDnaProfile?> getStyleProfile(String userId) async {
    final endpoint = '/ai/buyer/style-profile/$userId';
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      final data = _parseJsonResponse(response.data);
      return StyleDnaProfile.fromJson(data);
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Get personal trend forecasting
  Future<TrendData> getPersonalTrends(String userId) async {
    final endpoint = '/ai/buyer/trends/personal/$userId';
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data);
      return TrendData.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  // ============================================================
  // INVENTORY & TREND PREDICTION (Seller Analytics)
  // ============================================================

  /// Get trending styles for a category
  Future<TrendData> getCategoryTrends(String category) async {
    final endpoint = '/ai/seller/trends/$category';
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data);
      return TrendData.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  /// Get inventory forecast
  Future<List<InventoryForecast>> getInventoryForecast({
    required String sellerId,
    String? category,
    int? daysAhead,
  }) async {
    const endpoint = '/ai/seller/inventory/forecast';
    final requestData = {
      'sellerId': sellerId,
      if (category != null) 'category': category,
      if (daysAhead != null) 'daysAhead': daysAhead,
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data);
      
      final data = response.data as Map<String, dynamic>;
      final forecasts = data['forecasts'] as List<dynamic>? ?? [];
      
      return forecasts
          .map((f) => InventoryForecast.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get seller performance comparison
  Future<SellerPerformance> getSellerPerformance(String sellerId) async {
    final endpoint = '/ai/seller/trends/seller/$sellerId';
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data);
      return SellerPerformance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  /// Get color trend prediction
  Future<DemandPrediction> getColorTrendPrediction(String category) async {
    final endpoint = '/ai/seller/demand/forecast-color/$category';
    _log('POST', endpoint);
    
    try {
      final response = await _dio.post(endpoint);
      _log('POST', endpoint, response: response.data);
      return DemandPrediction.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get size demand prediction
  Future<DemandPrediction> getSizeDemandPrediction(String category) async {
    final endpoint = '/ai/seller/demand/forecast-size/$category';
    _log('POST', endpoint);
    
    try {
      final response = await _dio.post(endpoint);
      _log('POST', endpoint, response: response.data);
      return DemandPrediction.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get inventory optimization suggestions
  Future<Map<String, dynamic>> getInventoryOptimization({
    required String sellerId,
    required double budget,
  }) async {
    const endpoint = '/ai/seller/demand/inventory-optimize';
    final requestData = {
      'sellerId': sellerId,
      'budget': budget,
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get customer profile insights (for sellers)
  Future<Map<String, dynamic>> getCustomerProfile(String customerId) async {
    final endpoint = '/ai/seller/customer/profile/$customerId';
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }
}

/// Provider for AI API
final aiApiProvider = Provider<AiApi>((ref) {
  final dio = ref.watch(aiDioProvider);
  return AiApi(dio);
});
