import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ai_models.dart';
import 'ai_api.dart';

/// AI Repository
/// 
/// Provides a clean interface for AI features with error handling
/// and data transformation.
class AiRepository {
  AiRepository(this._api);

  final AiApi _api;

  // ============================================================
  // CULTURAL CONTEXT AI (Chat)
  // ============================================================

  Future<AiChatMessage> sendMessage({
    required String message,
    String? userId,
    String? context,
  }) async {
    return _api.sendChatMessage(
      message: message,
      userId: userId,
      context: context,
    );
  }

  Future<List<AiChatMessage>> getChatHistory(String userId) async {
    return _api.getChatHistory(userId);
  }

  // ============================================================
  // SMART PRODUCT DESCRIPTIONS
  // ============================================================

  Future<AiProductDescription> generateDescription({
    required String name,
    required String style,
    required String tribe,
    required String gender,
    required double price,
    String? materials,
    String? occasion,
    List<String>? colors,
  }) async {
    return _api.generateProductDescription(
      name: name,
      style: style,
      tribe: tribe,
      gender: gender,
      price: price,
      materials: materials,
      occasion: occasion,
      colors: colors,
    );
  }

  Future<List<AiProductDescription>> generateBatchDescriptions(
    List<ProductDescriptionRequest> products,
  ) async {
    return _api.generateBatchDescriptions(products);
  }

  // ============================================================
  // PERSONALIZATION (Style DNA & Recommendations)
  // ============================================================

  Future<StyleDnaProfile> submitStyleQuiz({
    required String userId,
    required List<StyleQuizAnswer> answers,
  }) async {
    return _api.submitStyleQuiz(userId: userId, answers: answers);
  }

  Future<List<PersonalizedRecommendation>> getRecommendations({
    required String userId,
    int? limit,
    String? category,
  }) async {
    return _api.getRecommendations(
      userId: userId,
      limit: limit,
      category: category,
    );
  }

  Future<StyleDnaProfile?> getStyleProfile(String userId) async {
    return _api.getStyleProfile(userId);
  }

  Future<TrendData> getPersonalTrends(String userId) async {
    return _api.getPersonalTrends(userId);
  }

  // ============================================================
  // INVENTORY & TREND PREDICTION (Seller Analytics)
  // ============================================================

  Future<TrendData> getCategoryTrends(String category) async {
    return _api.getCategoryTrends(category);
  }

  Future<List<InventoryForecast>> getInventoryForecast({
    required String sellerId,
    String? category,
    int? daysAhead,
  }) async {
    return _api.getInventoryForecast(
      sellerId: sellerId,
      category: category,
      daysAhead: daysAhead,
    );
  }

  Future<SellerPerformance> getSellerPerformance(String sellerId) async {
    return _api.getSellerPerformance(sellerId);
  }

  Future<DemandPrediction> getColorTrendPrediction(String category) async {
    return _api.getColorTrendPrediction(category);
  }

  Future<DemandPrediction> getSizeDemandPrediction(String category) async {
    return _api.getSizeDemandPrediction(category);
  }

  Future<Map<String, dynamic>> getInventoryOptimization({
    required String sellerId,
    required double budget,
  }) async {
    return _api.getInventoryOptimization(sellerId: sellerId, budget: budget);
  }

  Future<Map<String, dynamic>> getCustomerProfile(String customerId) async {
    return _api.getCustomerProfile(customerId);
  }
}

/// Provider for AI Repository
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final api = ref.watch(aiApiProvider);
  return AiRepository(api);
});
