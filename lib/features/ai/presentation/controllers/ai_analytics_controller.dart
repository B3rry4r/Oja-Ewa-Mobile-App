import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_repository.dart';
import '../../domain/ai_models.dart';

/// State for Seller Analytics Dashboard
class SellerAnalyticsState {
  const SellerAnalyticsState({
    this.isLoading = false,
    this.trends,
    this.forecasts,
    this.performance,
    this.colorPredictions,
    this.sizePredictions,
    this.error,
    this.selectedCategory = 'textiles',
  });

  final bool isLoading;
  final TrendData? trends;
  final List<InventoryForecast>? forecasts;
  final SellerPerformance? performance;
  final DemandPrediction? colorPredictions;
  final DemandPrediction? sizePredictions;
  final String? error;
  final String selectedCategory;

  SellerAnalyticsState copyWith({
    bool? isLoading,
    TrendData? trends,
    List<InventoryForecast>? forecasts,
    SellerPerformance? performance,
    DemandPrediction? colorPredictions,
    DemandPrediction? sizePredictions,
    String? error,
    String? selectedCategory,
  }) {
    return SellerAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      trends: trends ?? this.trends,
      forecasts: forecasts ?? this.forecasts,
      performance: performance ?? this.performance,
      colorPredictions: colorPredictions ?? this.colorPredictions,
      sizePredictions: sizePredictions ?? this.sizePredictions,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// Controller for Smart Inventory & Trend Analytics
class SellerAnalyticsController extends AsyncNotifier<SellerAnalyticsState> {
  String? _sellerId;

  @override
  FutureOr<SellerAnalyticsState> build() {
    return const SellerAnalyticsState();
  }

  /// Initialize analytics with seller ID
  Future<void> initialize(String sellerId) async {
    _sellerId = sellerId;
    await loadAllData();
  }

  /// Load all analytics data
  Future<void> loadAllData() async {
    if (_sellerId == null) return;

    final currentState = state.value ?? const SellerAnalyticsState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    try {
      final repository = ref.read(aiRepositoryProvider);
      
      // Load all data in parallel
      final results = await Future.wait([
        repository.getCategoryTrends(currentState.selectedCategory),
        repository.getInventoryForecast(sellerId: _sellerId!),
        repository.getSellerPerformance(_sellerId!),
        repository.getColorTrendPrediction(currentState.selectedCategory),
        repository.getSizeDemandPrediction(currentState.selectedCategory),
      ]);

      state = AsyncData(currentState.copyWith(
        isLoading: false,
        trends: results[0] as TrendData,
        forecasts: results[1] as List<InventoryForecast>,
        performance: results[2] as SellerPerformance,
        colorPredictions: results[3] as DemandPrediction,
        sizePredictions: results[4] as DemandPrediction,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: 'Failed to load analytics: ${e.toString()}',
      ));
    }
  }

  /// Change selected category and reload trends
  Future<void> selectCategory(String category) async {
    final currentState = state.value ?? const SellerAnalyticsState();
    state = AsyncData(currentState.copyWith(selectedCategory: category, isLoading: true));

    try {
      final repository = ref.read(aiRepositoryProvider);
      
      final results = await Future.wait([
        repository.getCategoryTrends(category),
        repository.getColorTrendPrediction(category),
        repository.getSizeDemandPrediction(category),
      ]);

      final updatedState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(updatedState.copyWith(
        isLoading: false,
        trends: results[0] as TrendData,
        colorPredictions: results[1] as DemandPrediction,
        sizePredictions: results[2] as DemandPrediction,
      ));
    } catch (e) {
      final updatedState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(updatedState.copyWith(
        isLoading: false,
        error: 'Failed to load category trends: ${e.toString()}',
      ));
    }
  }

  /// Refresh inventory forecasts
  Future<void> refreshForecasts({int? daysAhead}) async {
    if (_sellerId == null) return;

    try {
      final repository = ref.read(aiRepositoryProvider);
      final forecasts = await repository.getInventoryForecast(
        sellerId: _sellerId!,
        daysAhead: daysAhead,
      );
      final currentState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(currentState.copyWith(forecasts: forecasts));
    } catch (e) {
      final currentState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(currentState.copyWith(
        error: 'Failed to refresh forecasts: ${e.toString()}',
      ));
    }
  }

  /// Get inventory optimization suggestions
  Future<Map<String, dynamic>?> getOptimization(double budget) async {
    if (_sellerId == null) return null;

    try {
      final repository = ref.read(aiRepositoryProvider);
      return await repository.getInventoryOptimization(
        sellerId: _sellerId!,
        budget: budget,
      );
    } catch (e) {
      final currentState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(currentState.copyWith(
        error: 'Failed to get optimization: ${e.toString()}',
      ));
      return null;
    }
  }
}

/// Provider for Seller Analytics Controller
final sellerAnalyticsControllerProvider =
    AsyncNotifierProvider<SellerAnalyticsController, SellerAnalyticsState>(
        SellerAnalyticsController.new);

/// Provider for category trends (standalone)
final categoryTrendsProvider = FutureProvider.family<TrendData, String>(
  (ref, category) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.getCategoryTrends(category);
  },
);

/// Provider for inventory forecasts
final inventoryForecastProvider =
    FutureProvider.family<List<InventoryForecast>, String>(
  (ref, sellerId) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.getInventoryForecast(sellerId: sellerId);
  },
);

/// Provider for seller performance
final sellerPerformanceProvider =
    FutureProvider.family<SellerPerformance, String>(
  (ref, sellerId) async {
    final repository = ref.watch(aiRepositoryProvider);
    return repository.getSellerPerformance(sellerId);
  },
);

/// Categories available for analytics
const analyticsCategories = [
  ('textiles', 'Textiles'),
  ('shoes_bags', 'Shoes & Bags'),
  ('afro_beauty_products', 'Beauty Products'),
];
