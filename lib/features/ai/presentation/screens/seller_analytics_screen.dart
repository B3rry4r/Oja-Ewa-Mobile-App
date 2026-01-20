import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/app_header.dart';
import '../../../account/presentation/controllers/profile_controller.dart';
import '../../domain/ai_models.dart';
import '../controllers/ai_analytics_controller.dart';

/// Seller Analytics Dashboard Screen
/// 
/// Shows AI-powered inventory forecasting, trend predictions,
/// and smart analytics for sellers.
class SellerAnalyticsScreen extends ConsumerStatefulWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  ConsumerState<SellerAnalyticsScreen> createState() => _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends ConsumerState<SellerAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  // App consistent colors
  static const _backgroundColor = Color(0xFFFFFBF5);
  static const _cardColor = Color(0xFFF5E0CE);
  static const _primaryColor = Color(0xFFFDAF40);
  static const _textDark = Color(0xFF241508);
  static const _textSecondary = Color(0xFF777F84);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final user = ref.read(userProfileProvider).value;
    if (user != null && !_isInitialized) {
      _isInitialized = true;
      await ref.read(sellerAnalyticsControllerProvider.notifier)
          .initialize(user.id.toString());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(sellerAnalyticsControllerProvider);
    final state = stateAsync.value ?? const SellerAnalyticsState();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: _backgroundColor,
              iconColor: _textDark,
              title: const Text(
                'AI Analytics',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              showActions: false,
            ),

            // Category Pills
            _buildCategorySelector(state),
            const SizedBox(height: 16),

            // Tab Bar - matching app style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: _textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'Trends'),
                    Tab(text: 'Inventory'),
                    Tab(text: 'Performance'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      ),
                    )
                  : state.error != null
                      ? _buildErrorState(state.error!)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTrendsTab(state),
                            _buildInventoryTab(state),
                            _buildPerformanceTab(state),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(SellerAnalyticsState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: analyticsCategories.map((cat) {
          final (value, label) = cat;
          final isSelected = state.selectedCategory == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => ref
                  .read(sellerAnalyticsControllerProvider.notifier)
                  .selectCategory(value),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _primaryColor : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : _textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off, size: 40, color: _textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load analytics',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => ref.read(sellerAnalyticsControllerProvider.notifier).loadAllData(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(SellerAnalyticsState state) {
    if (state.trends == null) {
      return _buildEmptyState('No trend data available', Icons.trending_up);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.trends!.trendingStyles.isNotEmpty)
            _buildTrendCard('Trending Styles', state.trends!.trendingStyles, Icons.style),
          if (state.trends!.trendingColors.isNotEmpty)
            _buildTrendCard('Trending Colors', state.trends!.trendingColors, Icons.palette),
          if (state.trends!.trendingTribes.isNotEmpty)
            _buildTrendCard('Popular Cultures', state.trends!.trendingTribes, Icons.public),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, List<TrendItem> items, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildTrendItem(index + 1, item);
          }),
        ],
      ),
    );
  }

  Widget _buildTrendItem(int rank, TrendItem item) {
    final isPositive = (item.growth ?? 0) >= 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? _primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: rank <= 3 ? Colors.white : _textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: _textDark,
              ),
            ),
          ),
          if (item.growth != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
                ),
                const SizedBox(width: 2),
                Text(
                  '${item.growth!.abs().toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w500,
                    color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(String title, DemandPrediction prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, size: 18, color: _primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prediction.period,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Campton',
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...prediction.predictions.take(5).map((p) => _buildPredictionItem(p)),
          if (prediction.insights != null && prediction.insights!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: _primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.insights!.first,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        color: _textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPredictionItem(DemandPredictionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.item,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Campton',
                  color: _textDark,
                ),
              ),
              Text(
                '${(item.confidence * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.confidence,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(SellerAnalyticsState state) {
    if (state.forecasts == null || state.forecasts!.isEmpty) {
      return _buildEmptyState('No inventory forecasts available', Icons.inventory_2);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.forecasts!.length,
      itemBuilder: (context, index) {
        return _buildInventoryCard(state.forecasts![index]);
      },
    );
  }

  Widget _buildInventoryCard(InventoryForecast forecast) {
    final needsRestock = forecast.predictedDemand > forecast.currentStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: needsRestock
            ? Border.all(color: const Color(0xFFE57373), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  forecast.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ),
              if (needsRestock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, size: 12, color: Color(0xFFE57373)),
                      SizedBox(width: 4),
                      Text(
                        'Restock',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE57373),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStockIndicator('Current', forecast.currentStock, _textSecondary),
              Container(width: 1, height: 32, color: Colors.white),
              _buildStockIndicator('Predicted', forecast.predictedDemand, _primaryColor),
              Container(width: 1, height: 32, color: Colors.white),
              _buildStockIndicator('Recommended', forecast.recommendedStock, const Color(0xFF4CAF50)),
            ],
          ),
          if (forecast.confidence != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Confidence: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    color: _textSecondary,
                  ),
                ),
                Text(
                  '${(forecast.confidence! * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockIndicator(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Campton',
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(SellerAnalyticsState state) {
    if (state.performance == null) {
      return _buildEmptyState('No performance data available', Icons.bar_chart);
    }

    final perf = state.performance!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stats Cards - matching shop dashboard style
          Row(
            children: [
              _buildStatCard('Total Sales', '₦${_formatNumber(perf.totalSales)}'),
              const SizedBox(width: 12),
              _buildStatCard('Rating', '${perf.averageRating.toStringAsFixed(1)} ★'),
            ],
          ),
          const SizedBox(height: 16),

          // Market Position
          if (perf.marketComparison != null)
            _buildMarketPositionCard(perf.marketComparison!),

          // Top Products
          if (perf.topProducts.isNotEmpty)
            _buildTopProductsCard(perf.topProducts),

          // AI Suggestions
          if (perf.suggestions != null && perf.suggestions!.isNotEmpty)
            _buildSuggestionsCard(perf.suggestions!),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Campton',
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPositionCard(MarketComparison comparison) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Position',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Top ${comparison.percentile.toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const Text(
                      'of sellers',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      comparison.trend ?? 'Stable',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                    const Text(
                      'trend',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsCard(List<TopProduct> products) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Products',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...products.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Campton',
                        color: _textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${product.sales} sold',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard(List<String> suggestions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, size: 18, color: _primaryColor),
              SizedBox(width: 8),
              Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.take(3).map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Campton',
                      color: _textDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: _textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
