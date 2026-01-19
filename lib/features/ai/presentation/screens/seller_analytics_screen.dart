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
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFFBF5),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'AI Analytics',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              showActions: false,
            ),

            // Category Selector
            _buildCategorySelector(state),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFFDAF40),
                unselectedLabelColor: const Color(0xFF777F84),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFFFDAF40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Trends'),
                  Tab(text: 'Inventory'),
                  Tab(text: 'Performance'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
                      ),
                    )
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: analyticsCategories.map((cat) {
          final (value, label) = cat;
          final isSelected = state.selectedCategory == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => ref
                  .read(sellerAnalyticsControllerProvider.notifier)
                  .selectCategory(value),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFFDAF40),
              labelStyle: TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF777F84),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendsTab(SellerAnalyticsState state) {
    if (state.trends == null) {
      return _buildEmptyState('No trend data available');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendSection('Trending Styles', state.trends!.trendingStyles, Icons.style),
          const SizedBox(height: 20),
          _buildTrendSection('Trending Colors', state.trends!.trendingColors, Icons.palette),
          const SizedBox(height: 20),
          _buildTrendSection('Popular Cultures', state.trends!.trendingTribes, Icons.public),
          const SizedBox(height: 20),
          if (state.colorPredictions != null)
            _buildPredictionCard('Color Forecast', state.colorPredictions!),
          const SizedBox(height: 20),
          if (state.sizePredictions != null)
            _buildPredictionCard('Size Demand', state.sizePredictions!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrendSection(String title, List<TrendItem> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFDAF40)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
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
    final growthColor = (item.growth ?? 0) >= 0
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE57373);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? const Color(0xFFFDAF40).withOpacity(0.2)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: rank <= 3
                      ? const Color(0xFFFDAF40)
                      : const Color(0xFF777F84),
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
                color: Color(0xFF241508),
              ),
            ),
          ),
          if (item.growth != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: growthColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.growth! >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: growthColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.growth!.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w500,
                      color: growthColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(String title, DemandPrediction prediction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, size: 20, color: Color(0xFFFDAF40)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
              const Spacer(),
              Text(
                prediction.period,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Campton',
                  color: Color(0xFF777F84),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...prediction.predictions.take(5).map((p) => _buildPredictionItem(p)),
          if (prediction.insights != null && prediction.insights!.isNotEmpty) ...[
            const Divider(height: 24),
            ...prediction.insights!.take(2).map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFFDAF40)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        color: const Color(0xFF241508).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildPredictionItem(DemandPredictionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.item,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Campton',
                color: Color(0xFF241508),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.confidence,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDAF40)),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(item.confidence * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF777F84),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(SellerAnalyticsState state) {
    if (state.forecasts == null || state.forecasts!.isEmpty) {
      return _buildEmptyState('No inventory forecasts available');
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: needsRestock
            ? Border.all(color: const Color(0xFFE57373).withOpacity(0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
                    color: Color(0xFF241508),
                  ),
                ),
              ),
              if (needsRestock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Restock Needed',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE57373),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStockIndicator('Current', forecast.currentStock, const Color(0xFF777F84)),
              const SizedBox(width: 16),
              _buildStockIndicator('Predicted', forecast.predictedDemand, const Color(0xFFFDAF40)),
              const SizedBox(width: 16),
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
                    color: Color(0xFF777F84),
                  ),
                ),
                Text(
                  '${(forecast.confidence! * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFDAF40),
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
              fontSize: 20,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Campton',
              color: Color(0xFF777F84),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(SellerAnalyticsState state) {
    if (state.performance == null) {
      return _buildEmptyState('No performance data available');
    }

    final perf = state.performance!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Sales', '₦${_formatNumber(perf.totalSales)}', Icons.payments)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Rating', perf.averageRating.toStringAsFixed(1), Icons.star)),
            ],
          ),
          const SizedBox(height: 20),

          // Market Comparison
          if (perf.marketComparison != null)
            _buildMarketComparisonCard(perf.marketComparison!),
          const SizedBox(height: 20),

          // Top Products
          if (perf.topProducts.isNotEmpty)
            _buildTopProductsCard(perf.topProducts),
          const SizedBox(height: 20),

          // Suggestions
          if (perf.suggestions != null && perf.suggestions!.isNotEmpty)
            _buildSuggestionsCard(perf.suggestions!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFFFDAF40)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Campton',
              color: Color(0xFF777F84),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketComparisonCard(MarketComparison comparison) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
              color: Color(0xFF241508),
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
                        fontSize: 28,
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
                        color: Color(0xFF777F84),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: const Color(0xFFEEEEEE)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      comparison.trend ?? 'Stable',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Campton',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFDAF40),
                      ),
                    ),
                    const Text(
                      'trend',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Campton',
                        color: Color(0xFF777F84),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
              color: Color(0xFF241508),
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
                      color: const Color(0xFFFDAF40).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFDAF40),
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
                        color: Color(0xFF241508),
                      ),
                    ),
                  ),
                  Text(
                    '${product.sales} sold',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Campton',
                      color: Color(0xFF777F84),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFDAF40).withOpacity(0.1),
            const Color(0xFFFFCC80).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDAF40).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, size: 20, color: Color(0xFFFDAF40)),
              SizedBox(width: 8),
              Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: Color(0xFFFDAF40), fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      color: Color(0xFF241508),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: const Color(0xFF241508).withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              color: const Color(0xFF241508).withOpacity(0.5),
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
