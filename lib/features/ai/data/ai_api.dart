import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_clients.dart';
import '../domain/ai_models.dart';

/// AI API Service
/// 
/// Handles AI-related API calls for the 4 boss-priority features:
/// 1. Smart Product Descriptions (Seller)
/// 2. Cultural Context AI Chat (Buyer)
/// 3. Style Quiz & Recommendations (Buyer)
/// 4. Seller Analytics (Seller)
/// 
/// Base URL: https://ojaewa-ai-production.up.railway.app
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

  /// Safely parse JSON response
  Map<String, dynamic> _parseJsonResponse(dynamic responseData) {
    if (responseData is String) {
      if (responseData.contains('<!DOCTYPE') || responseData.contains('<html')) {
        throw Exception('AI API returned HTML instead of JSON. Check AI_BASE_URL configuration.');
      }
      throw Exception('AI API returned unexpected string response');
    }
    if (responseData is! Map<String, dynamic>) {
      throw Exception('AI API returned unexpected response type: ${responseData.runtimeType}');
    }
    return responseData;
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  // ============================================================
  // FEATURE 1: CULTURAL CONTEXT AI CHAT
  // ============================================================

  /// Send a message to the AI chat assistant
  /// POST /ai/buyer/chat
  Future<AiChatMessage> sendChatMessage({
    required String message,
    Map<String, dynamic>? context,
  }) async {
    const endpoint = '/ai/buyer/chat';
    final requestData = {
      'message': message,
      if (context != null) 'context': context,
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      
      // Response format: { success, response, suggestedProducts[], sessionId }
      return AiChatMessage(
        id: data['sessionId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        content: data['response']?.toString() ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: null,
        products: (data['suggestedProducts'] as List<dynamic>?)
            ?.map((p) {
              if (p is! Map<String, dynamic>) return null;
              return AiSuggestedProduct(
                id: p['id']?.toString() ?? '',
                name: p['name']?.toString() ?? '',
                price: _parseDouble(p['price']),
                imageUrl: p['image']?.toString(),
                description: p['matchReason']?.toString(),
              );
            })
            .whereType<AiSuggestedProduct>()
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
  /// GET /ai/buyer/chat/history/{userId}
  /// Response formats:
  /// 1) { history: [{ id, role, content, timestamp }] }
  /// 2) { history: [{ id, userMessage, assistantResponse, timestamp }] }
  Future<List<AiChatMessage>> getChatHistory(String userId) async {
    final endpoint = '/ai/buyer/chat/history/$userId';
    
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      final history = data['history'] as List<dynamic>? ?? [];
      
      final messages = <AiChatMessage>[];
      for (final item in history) {
        if (item is! Map<String, dynamic>) continue;

        // Format 1: role/content
        if (item.containsKey('role') && item.containsKey('content')) {
          messages.add(AiChatMessage(
            id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            content: item['content']?.toString() ?? '',
            isUser: item['role'] == 'user',
            timestamp: _parseDateTime(item['timestamp']),
          ));
          continue;
        }

        // Format 2: userMessage + assistantResponse
        if (item['userMessage'] != null || item['assistantResponse'] != null) {
          final timestamp = _parseDateTime(item['timestamp']);
          if (item['userMessage'] != null) {
            messages.add(AiChatMessage(
              id: '${item['id'] ?? DateTime.now().millisecondsSinceEpoch}_user',
              content: item['userMessage']?.toString() ?? '',
              isUser: true,
              timestamp: timestamp,
            ));
          }
          if (item['assistantResponse'] != null) {
            messages.add(AiChatMessage(
              id: '${item['id'] ?? DateTime.now().millisecondsSinceEpoch}_assistant',
              content: item['assistantResponse']?.toString() ?? '',
              isUser: false,
              timestamp: timestamp,
            ));
          }
        }
      }
      return messages;
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  // ============================================================
  // FEATURE 2: STYLE QUIZ & PERSONALIZED RECOMMENDATIONS
  // ============================================================

  /// Submit style quiz answers
  /// POST /ai/buyer/style-quiz
  /// Request: { answers: { preferredStyle, favoriteColors[], occasions[], ... } }
  Future<StyleDnaProfile> submitStyleQuiz({
    required String userId,
    required Map<String, dynamic> answers,
  }) async {
    const endpoint = '/ai/buyer/style-quiz';
    final requestData = {'answers': answers};
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      final styleProfile = data['styleProfile'] as Map<String, dynamic>? ?? {};
      
      return StyleDnaProfile(
        userId: userId,
        styleProfile: styleProfile['summary']?.toString() ?? 'Style profile created',
        colorSeason: null,
        preferredStyles: styleProfile['stylePersonality'] != null 
            ? [styleProfile['stylePersonality'].toString()] 
            : null,
        preferredTribes: (styleProfile['culturalAffinity'] as List<dynamic>?)?.cast<String>(),
        bodyType: styleProfile['fitPreference']?.toString(),
        fashionGoals: (styleProfile['occasionFocus'] as List<dynamic>?)?.cast<String>(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      _log('POST', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  /// Get personalized recommendations for a user
  /// GET /ai/buyer/recommendations/{userId}?limit=&category=
  /// Response: { success, source, recommendations: [{ productId, matchScore, reason, product }], insight }
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
      
      final data = _parseJsonResponse(response.data);
      final recommendations = data['recommendations'] as List<dynamic>? ?? [];
      
      return recommendations.map((item) {
        if (item is! Map<String, dynamic>) {
          return const PersonalizedRecommendation(id: '', name: '', price: 0, matchScore: 0);
        }
        
        final product = item['product'] as Map<String, dynamic>? ?? {};
        
        return PersonalizedRecommendation(
          id: item['productId']?.toString() ?? product['id']?.toString() ?? '',
          name: product['name']?.toString() ?? '',
          price: _parseDouble(product['price']),
          matchScore: _parseDouble(item['matchScore']) / 100, // Convert 0-100 to 0-1
          imageUrl: product['image']?.toString(),
          reason: item['reason']?.toString(),
          category: null,
          style: null,
          tribe: null,
        );
      }).toList();
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  /// Get user's style profile (if exists)
  /// Note: This may not exist as a separate endpoint - using recommendations insight
  Future<StyleDnaProfile?> getStyleProfile(String userId) async {
    // The API doesn't have a separate get-profile endpoint
    // We can try to get recommendations which includes profile info
    try {
      final recommendations = await getRecommendations(userId: userId, limit: 1);
      if (recommendations.isEmpty) return null;
      // If we got recommendations, user has a profile
      return StyleDnaProfile(
        userId: userId,
        styleProfile: 'Your personalized style profile',
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // FEATURE 3: SMART PRODUCT DESCRIPTIONS
  // ============================================================

  /// Generate AI product description
  /// POST /ai/seller/products/generate-description
  /// Request: { name, category, attributes: { fabric, style, occasion } }
  Future<AiProductDescription> generateProductDescription({
    required String name,
    required String category,
    String? fabric,
    String? style,
    String? occasion,
  }) async {
    const endpoint = '/ai/seller/products/generate-description';
    final requestData = {
      'name': name,
      'category': category,
      'attributes': {
        if (fabric != null) 'fabric': fabric,
        if (style != null) 'style': style,
        if (occasion != null) 'occasion': occasion,
      },
    };
    
    _log('POST', endpoint, data: requestData);
    
    try {
      final response = await _dio.post(endpoint, data: requestData);
      _log('POST', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      
      return AiProductDescription(
        description: data['description']?.toString() ?? '',
        title: data['seoTitle']?.toString(),
        tags: (data['bulletPoints'] as List<dynamic>?)?.cast<String>(),
        seoKeywords: (data['seoKeywords'] as List<dynamic>?)?.cast<String>(),
      );
    } on DioException catch (e) {
      _log('POST', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('POST', endpoint, error: e);
      rethrow;
    }
  }

  // ============================================================
  // FEATURE 4: SELLER ANALYTICS (Trends & Inventory)
  // ============================================================

  /// Get upcoming trends for a category
  /// GET /ai/buyer/trends/upcoming/{category}
  /// Categories: textiles, shoes_bags, afro_beauty_products, art
  Future<TrendData> getCategoryTrends(String category) async {
    final endpoint = '/ai/buyer/trends/upcoming/$category';
    
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      final trends = data['trends'] as List<dynamic>? ?? [];
      
      return TrendData(
        category: data['category']?.toString() ?? category,
        trendingStyles: trends.map((t) {
          if (t is! Map<String, dynamic>) return const TrendItem(name: '', score: 0);
          final popularity = t['popularity']?.toString() ?? '';
          return TrendItem(
            name: t['name']?.toString() ?? '',
            score: popularity == 'rising' ? 0.9 : popularity == 'stable' ? 0.6 : 0.3,
            growth: popularity == 'rising' ? 15.0 : popularity == 'stable' ? 0.0 : -10.0,
          );
        }).toList(),
        trendingColors: [],
        trendingTribes: [],
        period: (data['seasonalFactors'] as List<dynamic>?)?.join(', '),
        confidence: null,
      );
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  /// Get sales analytics for a seller
  /// GET /ai/seller/analytics/sales/{sellerId}?period=30days
  Future<SellerPerformance> getSellerPerformance(String sellerId) async {
    final endpoint = '/ai/seller/analytics/sales/$sellerId';
    
    _log('GET', endpoint, data: {'period': '30days'});
    
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {'period': '30days'},
      );
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      
      return SellerPerformance(
        sellerId: sellerId,
        totalSales: _parseDouble(data['totalSales'] ?? data['total_sales']),
        averageRating: _parseDouble(data['averageRating'] ?? data['average_rating']),
        topProducts: (data['topProducts'] as List<dynamic>? ?? []).map((p) {
          if (p is! Map<String, dynamic>) return const TopProduct(id: '', name: '', sales: 0);
          return TopProduct(
            id: p['id']?.toString() ?? '',
            name: p['name']?.toString() ?? '',
            sales: (p['sales'] as num?)?.toInt() ?? 0,
            revenue: _parseDouble(p['revenue']),
          );
        }).toList(),
        marketComparison: null,
        suggestions: (data['insights'] as List<dynamic>?)?.cast<String>() ??
            (data['suggestions'] as List<dynamic>?)?.cast<String>(),
      );
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
    } catch (e) {
      _log('GET', endpoint, error: e);
      rethrow;
    }
  }

  /// Get inventory insights for a seller
  /// GET /ai/seller/analytics/inventory/{sellerId}
  Future<List<InventoryForecast>> getInventoryForecast({
    required String sellerId,
    String? category,
    int? daysAhead,
  }) async {
    final endpoint = '/ai/seller/analytics/inventory/$sellerId';
    
    _log('GET', endpoint);
    
    try {
      final response = await _dio.get(endpoint);
      _log('GET', endpoint, response: response.data, statusCode: response.statusCode);
      
      final data = _parseJsonResponse(response.data);
      final items = data['items'] as List<dynamic>? ?? 
                    data['inventory'] as List<dynamic>? ?? 
                    data['forecasts'] as List<dynamic>? ?? [];
      
      return items.map((item) {
        if (item is! Map<String, dynamic>) {
          return const InventoryForecast(
            productId: '', productName: '', currentStock: 0, 
            predictedDemand: 0, recommendedStock: 0,
          );
        }
        return InventoryForecast(
          productId: item['productId']?.toString() ?? item['product_id']?.toString() ?? '',
          productName: item['productName']?.toString() ?? item['name']?.toString() ?? '',
          currentStock: (item['currentStock'] as num?)?.toInt() ?? 
                        (item['stock'] as num?)?.toInt() ?? 0,
          predictedDemand: (item['predictedDemand'] as num?)?.toInt() ?? 
                           (item['demand'] as num?)?.toInt() ?? 0,
          recommendedStock: (item['recommendedStock'] as num?)?.toInt() ?? 
                            (item['recommended'] as num?)?.toInt() ?? 0,
          confidence: _parseDouble(item['confidence']),
        );
      }).toList();
    } on DioException catch (e) {
      _log('GET', endpoint, error: e.message, statusCode: e.response?.statusCode);
      rethrow;
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
