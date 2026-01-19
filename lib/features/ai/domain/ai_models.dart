/// AI Feature Domain Models
/// 
/// Contains all data models for AI features:
/// - Smart Product Descriptions
/// - Cultural Context AI Chat
/// - Client Relationship & Personalization
/// - Smart Inventory & Trend Prediction

// ============================================================
// CHAT MODELS (Cultural Context AI)
// ============================================================

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.products,
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final List<AiSuggestedProduct>? products;

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['response'] as String? ?? json['message'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : DateTime.now(),
      suggestions: (json['suggestions'] as List<dynamic>?)?.cast<String>(),
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => AiSuggestedProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'suggestions': suggestions,
    'products': products?.map((p) => p.toJson()).toList(),
  };
}

class AiSuggestedProduct {
  const AiSuggestedProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;

  factory AiSuggestedProduct.fromJson(Map<String, dynamic> json) {
    return AiSuggestedProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'description': description,
  };
}

// ============================================================
// PRODUCT DESCRIPTION MODELS
// ============================================================

class AiProductDescription {
  const AiProductDescription({
    required this.description,
    this.title,
    this.tags,
    this.seoKeywords,
  });

  final String description;
  final String? title;
  final List<String>? tags;
  final List<String>? seoKeywords;

  factory AiProductDescription.fromJson(Map<String, dynamic> json) {
    return AiProductDescription(
      description: json['description'] as String? ?? '',
      title: json['title'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      seoKeywords: (json['seoKeywords'] as List<dynamic>?)?.cast<String>() ??
          (json['seo_keywords'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class ProductDescriptionRequest {
  const ProductDescriptionRequest({
    required this.name,
    required this.style,
    required this.tribe,
    required this.gender,
    required this.price,
    this.materials,
    this.occasion,
    this.colors,
  });

  final String name;
  final String style;
  final String tribe;
  final String gender;
  final double price;
  final String? materials;
  final String? occasion;
  final List<String>? colors;

  Map<String, dynamic> toJson() => {
    'name': name,
    'style': style,
    'tribe': tribe,
    'gender': gender,
    'price': price,
    if (materials != null) 'materials': materials,
    if (occasion != null) 'occasion': occasion,
    if (colors != null) 'colors': colors,
  };
}

// ============================================================
// PERSONALIZATION MODELS (Style DNA & Recommendations)
// ============================================================

class StyleDnaProfile {
  const StyleDnaProfile({
    required this.userId,
    required this.styleProfile,
    this.colorSeason,
    this.preferredStyles,
    this.preferredTribes,
    this.bodyType,
    this.fashionGoals,
    this.updatedAt,
  });

  final String userId;
  final String styleProfile;
  final String? colorSeason;
  final List<String>? preferredStyles;
  final List<String>? preferredTribes;
  final String? bodyType;
  final List<String>? fashionGoals;
  final DateTime? updatedAt;

  factory StyleDnaProfile.fromJson(dynamic jsonData) {
    // Handle case where jsonData might not be a Map
    if (jsonData is! Map<String, dynamic>) {
      return const StyleDnaProfile(
        userId: '',
        styleProfile: 'Style profile not available',
      );
    }
    
    final json = jsonData;
    
    // Safely parse list of strings
    List<String>? parseStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return null;
    }
    
    // Safely parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }
    
    return StyleDnaProfile(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      styleProfile: json['styleProfile']?.toString() ?? json['style_profile']?.toString() ?? '',
      colorSeason: json['colorSeason']?.toString() ?? json['color_season']?.toString(),
      preferredStyles: parseStringList(json['preferredStyles'] ?? json['preferred_styles']),
      preferredTribes: parseStringList(json['preferredTribes'] ?? json['preferred_tribes']),
      bodyType: json['bodyType']?.toString() ?? json['body_type']?.toString(),
      fashionGoals: parseStringList(json['fashionGoals'] ?? json['fashion_goals']),
      updatedAt: parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }
}

class StyleQuizAnswer {
  const StyleQuizAnswer({
    required this.questionId,
    required this.answer,
  });

  final String questionId;
  final String answer;

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'answer': answer,
  };
}

class PersonalizedRecommendation {
  const PersonalizedRecommendation({
    required this.id,
    required this.name,
    required this.price,
    required this.matchScore,
    this.imageUrl,
    this.reason,
    this.category,
    this.style,
    this.tribe,
  });

  final String id;
  final String name;
  final double price;
  final double matchScore;
  final String? imageUrl;
  final String? reason;
  final String? category;
  final String? style;
  final String? tribe;

  factory PersonalizedRecommendation.fromJson(dynamic jsonData) {
    // Handle case where jsonData might be a String or other non-map type
    if (jsonData is! Map<String, dynamic>) {
      return const PersonalizedRecommendation(
        id: '',
        name: 'Unknown Product',
        price: 0.0,
        matchScore: 0.0,
      );
    }
    
    final json = jsonData;
    
    // Safely parse price which might come as String
    double parsePrice(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return PersonalizedRecommendation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parsePrice(json['price']),
      matchScore: parsePrice(json['matchScore'] ?? json['match_score']),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      reason: json['reason']?.toString(),
      category: json['category']?.toString(),
      style: json['style']?.toString(),
      tribe: json['tribe']?.toString(),
    );
  }
}

// ============================================================
// INVENTORY & TREND MODELS (Seller Analytics)
// ============================================================

class TrendData {
  const TrendData({
    required this.category,
    required this.trendingStyles,
    required this.trendingColors,
    required this.trendingTribes,
    this.period,
    this.confidence,
  });

  final String category;
  final List<TrendItem> trendingStyles;
  final List<TrendItem> trendingColors;
  final List<TrendItem> trendingTribes;
  final String? period;
  final double? confidence;

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      category: json['category'] as String? ?? '',
      trendingStyles: (json['trendingStyles'] as List<dynamic>? ?? 
          json['trending_styles'] as List<dynamic>? ?? [])
          .map((e) => TrendItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingColors: (json['trendingColors'] as List<dynamic>? ?? 
          json['trending_colors'] as List<dynamic>? ?? [])
          .map((e) => TrendItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingTribes: (json['trendingTribes'] as List<dynamic>? ?? 
          json['trending_tribes'] as List<dynamic>? ?? [])
          .map((e) => TrendItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      period: json['period'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

class TrendItem {
  const TrendItem({
    required this.name,
    required this.score,
    this.growth,
    this.previousRank,
    this.currentRank,
  });

  final String name;
  final double score;
  final double? growth;
  final int? previousRank;
  final int? currentRank;

  factory TrendItem.fromJson(Map<String, dynamic> json) {
    return TrendItem(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      growth: (json['growth'] as num?)?.toDouble(),
      previousRank: json['previousRank'] as int? ?? json['previous_rank'] as int?,
      currentRank: json['currentRank'] as int? ?? json['current_rank'] as int?,
    );
  }
}

class InventoryForecast {
  const InventoryForecast({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.predictedDemand,
    required this.recommendedStock,
    this.confidence,
    this.seasonalFactor,
    this.trendFactor,
  });

  final String productId;
  final String productName;
  final int currentStock;
  final int predictedDemand;
  final int recommendedStock;
  final double? confidence;
  final double? seasonalFactor;
  final double? trendFactor;

  factory InventoryForecast.fromJson(Map<String, dynamic> json) {
    return InventoryForecast(
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['productName'] as String? ?? json['product_name'] as String? ?? '',
      currentStock: json['currentStock'] as int? ?? json['current_stock'] as int? ?? 0,
      predictedDemand: json['predictedDemand'] as int? ?? json['predicted_demand'] as int? ?? 0,
      recommendedStock: json['recommendedStock'] as int? ?? json['recommended_stock'] as int? ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble(),
      seasonalFactor: (json['seasonalFactor'] as num?)?.toDouble() ?? 
          (json['seasonal_factor'] as num?)?.toDouble(),
      trendFactor: (json['trendFactor'] as num?)?.toDouble() ?? 
          (json['trend_factor'] as num?)?.toDouble(),
    );
  }
}

class DemandPrediction {
  const DemandPrediction({
    required this.category,
    required this.period,
    required this.predictions,
    this.insights,
  });

  final String category;
  final String period;
  final List<DemandPredictionItem> predictions;
  final List<String>? insights;

  factory DemandPrediction.fromJson(Map<String, dynamic> json) {
    return DemandPrediction(
      category: json['category'] as String? ?? '',
      period: json['period'] as String? ?? '',
      predictions: (json['predictions'] as List<dynamic>? ?? [])
          .map((e) => DemandPredictionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class DemandPredictionItem {
  const DemandPredictionItem({
    required this.item,
    required this.predictedDemand,
    required this.confidence,
    this.recommendation,
  });

  final String item;
  final int predictedDemand;
  final double confidence;
  final String? recommendation;

  factory DemandPredictionItem.fromJson(Map<String, dynamic> json) {
    return DemandPredictionItem(
      item: json['item'] as String? ?? json['name'] as String? ?? '',
      predictedDemand: json['predictedDemand'] as int? ?? 
          json['predicted_demand'] as int? ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendation: json['recommendation'] as String?,
    );
  }
}

class SellerPerformance {
  const SellerPerformance({
    required this.sellerId,
    required this.totalSales,
    required this.averageRating,
    required this.topProducts,
    this.marketComparison,
    this.suggestions,
  });

  final String sellerId;
  final double totalSales;
  final double averageRating;
  final List<TopProduct> topProducts;
  final MarketComparison? marketComparison;
  final List<String>? suggestions;

  factory SellerPerformance.fromJson(Map<String, dynamic> json) {
    return SellerPerformance(
      sellerId: json['sellerId']?.toString() ?? json['seller_id']?.toString() ?? '',
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 
          (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 
          (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      topProducts: (json['topProducts'] as List<dynamic>? ?? 
          json['top_products'] as List<dynamic>? ?? [])
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      marketComparison: json['marketComparison'] != null 
          ? MarketComparison.fromJson(json['marketComparison'] as Map<String, dynamic>)
          : json['market_comparison'] != null
              ? MarketComparison.fromJson(json['market_comparison'] as Map<String, dynamic>)
              : null,
      suggestions: (json['suggestions'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class TopProduct {
  const TopProduct({
    required this.id,
    required this.name,
    required this.sales,
    this.revenue,
  });

  final String id;
  final String name;
  final int sales;
  final double? revenue;

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sales: json['sales'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble(),
    );
  }
}

class MarketComparison {
  const MarketComparison({
    required this.percentile,
    required this.averageMarketSales,
    this.trend,
  });

  final double percentile;
  final double averageMarketSales;
  final String? trend;

  factory MarketComparison.fromJson(Map<String, dynamic> json) {
    return MarketComparison(
      percentile: (json['percentile'] as num?)?.toDouble() ?? 0.0,
      averageMarketSales: (json['averageMarketSales'] as num?)?.toDouble() ?? 
          (json['average_market_sales'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] as String?,
    );
  }
}
