import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ai_models.dart';
import 'ai_api.dart';

/// AI Repository
/// 
/// Provides a clean interface for the 4 boss-priority AI features:
/// 1. Cultural Context AI Chat
/// 2. Style Quiz & Personalized Recommendations  
/// 3. Smart Product Descriptions
/// 4. Seller Analytics (Trends & Inventory)
class AiRepository {
  AiRepository(this._api);

  final AiApi _api;

  // ============================================================
  // FEATURE 1: CULTURAL CONTEXT AI CHAT
  // ============================================================

  Future<AiChatMessage> sendMessage({
    required String message,
    Map<String, dynamic>? context,
  }) async {
    return _api.sendChatMessage(message: message, context: context);
  }

  Future<List<AiChatMessage>> getChatHistory(String userId) async {
    return _api.getChatHistory(userId);
  }

  // ============================================================
  // FEATURE 2: STYLE QUIZ & PERSONALIZED RECOMMENDATIONS
  // ============================================================

  Future<StyleDnaProfile> submitStyleQuiz({
    required String userId,
    required Map<String, dynamic> answers,
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

  // ============================================================
  // FEATURE 3: SMART PRODUCT DESCRIPTIONS
  // ============================================================

  Future<AiProductDescription> generateDescription({
    required String name,
    required String category,
    String? fabric,
    String? style,
    String? occasion,
  }) async {
    return _api.generateProductDescription(
      name: name,
      category: category,
      fabric: fabric,
      style: style,
      occasion: occasion,
    );
  }

  // ============================================================
  // FEATURE 4: SELLER ANALYTICS (Trends & Inventory)
  // ============================================================

  Future<TrendData> getCategoryTrends(String category) async {
    return _api.getCategoryTrends(category);
  }

  Future<SellerPerformance> getSellerPerformance(String sellerId) async {
    return _api.getSellerPerformance(sellerId);
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
}

/// Provider for AI Repository
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final api = ref.watch(aiApiProvider);
  return AiRepository(api);
});
