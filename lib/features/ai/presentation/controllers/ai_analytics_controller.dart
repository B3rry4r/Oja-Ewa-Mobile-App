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
    this.error,
    this.selectedCategory = 'textiles',
  });

  final bool isLoading;
  final TrendData? trends;
  final List<InventoryForecast>? forecasts;
  final String? error;
  final String selectedCategory;

  SellerAnalyticsState copyWith({
    bool? isLoading,
    TrendData? trends,
    List<InventoryForecast>? forecasts,
    String? error,
    String? selectedCategory,
  }) {
    return SellerAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      trends: trends ?? this.trends,
      forecasts: forecasts ?? this.forecasts,
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

      // Load trends + inventory in parallel
      final results = await Future.wait([
        repository.getCategoryTrends(currentState.selectedCategory),
        repository.getInventoryForecast(sellerId: _sellerId!),
      ]);

      state = AsyncData(currentState.copyWith(
        isLoading: false,
        trends: results[0] as TrendData,
        forecasts: results[1] as List<InventoryForecast>,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(
        isLoading: false,
        error: 'Unable to load analytics. Please try again.',
      ));
    }
  }

  /// Change selected category and reload trends
  Future<void> selectCategory(String category) async {
    final currentState = state.value ?? const SellerAnalyticsState();
    state = AsyncData(currentState.copyWith(selectedCategory: category, isLoading: true));

    try {
      final repository = ref.read(aiRepositoryProvider);
      final trends = await repository.getCategoryTrends(category);

      final updatedState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(updatedState.copyWith(
        isLoading: false,
        trends: trends,
      ));
    } catch (e) {
      final updatedState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(updatedState.copyWith(
        isLoading: false,
        error: 'Unable to load category trends. Please try again.',
      ));
    }
  }

  /// Refresh inventory forecasts
  Future<void> refreshForecasts() async {
    if (_sellerId == null) return;

    try {
      final repository = ref.read(aiRepositoryProvider);
      final forecasts = await repository.getInventoryForecast(
        sellerId: _sellerId!,
      );
      final currentState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(currentState.copyWith(forecasts: forecasts));
    } catch (e) {
      final currentState = state.value ?? const SellerAnalyticsState();
      state = AsyncData(currentState.copyWith(
        error: 'Unable to refresh inventory data.',
      ));
    }
  }
}

/// Provider for Seller Analytics Controller
final sellerAnalyticsControllerProvider =
    AsyncNotifierProvider<SellerAnalyticsController, SellerAnalyticsState>(
        SellerAnalyticsController.new);

/// Categories available for analytics
const analyticsCategories = [
  ('textiles', 'Textiles'),
  ('shoes_bags', 'Shoes & Bags'),
  ('afro_beauty_products', 'Beauty Products'),
  ('art', 'Art'),
];
