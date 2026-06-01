import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/widgets/seller_badge.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/presentation/controllers/seller_status_controller.dart';
import 'package:ojaewa/features/account/subfeatures/start_selling/domain/seller_status.dart';
import 'package:ojaewa/features/your_shop/presentation/controllers/seller_orders_controller.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';
import 'package:ojaewa/features/ai/presentation/controllers/ai_analytics_controller.dart';

import '../../../app/router/app_router.dart';
import '../subfeatures/product/product_listing.dart';
import '../subfeatures/orders/orders.dart';
import '../../your_shop/data/seller_product_repository.dart';

// Import seller products provider
final sellerProductsProvider = FutureProvider<List<dynamic>>((
  ref,
) async {
  final repo = ref.watch(sellerProductRepositoryProvider);
  try {
    final products = await repo.getMyProducts(perPage: 100);
    debugPrint('ShopDashboard: Loaded ${products.length} products');
    return products;
  } catch (e, st) {
    debugPrint('ShopDashboard: Error loading products: $e');
    debugPrint('ShopDashboard: Stack trace: $st');
    rethrow;
  }
});

class ShopDashboardScreen extends ConsumerStatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  ConsumerState<ShopDashboardScreen> createState() =>
      _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends ConsumerState<ShopDashboardScreen> {
  bool _isAnalyticsLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sellerStatus = ref.watch(sellerStatusProvider);
    final processingOrders = ref.watch(sellerOrdersProvider('processing'));
    final allOrders = ref.watch(sellerOrdersProvider(null));
    final userId = ref.watch(userProfileProvider).value?.id.toString();
    final sellerProducts = ref.watch(sellerProductsProvider);

    return AppPageScaffold(
      title: context.l10n.sellerShopTitle,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShopHeader(context, sellerStatus),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildStatsRow(
            context,
            allOrders.maybeWhen(data: (o) => o.length, orElse: () => 0),
            sellerProducts.maybeWhen(data: (p) => p.length, orElse: () => 0),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 32),
          Text(
            context.l10n.sellerOrdersInProcess,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildOrdersTable(processingOrders),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context, SellerStatus? sellerStatus) {
    final colors = context.appColors;
    final businessName = sellerStatus?.businessName ?? '';
    final badge = sellerStatus?.badge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (businessName.isNotEmpty) ...[
                Text(
                  businessName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 6),
                  SellerBadge(badge: badge),
                ],
              ] else
                Text(
                  context.l10n.sellerShopTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageShop),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              context.l10n.sellerManageShop,
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: WBColors.surfaceInput,
        borderRadius: BorderRadius.circular(WBRadius.input),
      ),
      child: Row(
        children: [
          const WBIcon(WBIconName.search, size: 20),
          const SizedBox(width: 12),
          Text(
            context.l10n.sellerSearchShop,
            style: WBTypography.body.copyWith(
              color: WBColors.fgPlaceholder,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    int ordersCount,
    int productsCount,
  ) {
    return Row(
      children: [
        _buildStatCard(
          label: context.l10n.sellerProducts,
          count: productsCount.toString(),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductListingsScreen()),
            );
          },
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          label: context.l10n.sellerOrders,
          count: ordersCount.toString(),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ShopOrdersScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    VoidCallback? onTap,
  }) {
    final colors = context.appColors;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WBColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: WBShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    context.l10n.sellerView,
                    style: TextStyle(fontSize: 10, color: colors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: colors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTable(AsyncValue<List<SellerOrder>> ordersAsync) {
    final colors = context.appColors;
    return ordersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Failed to load orders',
            style: TextStyle(color: colors.textTertiary),
          ),
        ),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No processing orders',
                style: TextStyle(color: colors.textTertiary),
              ),
            ),
          );
        }

        final dateFormat = DateFormat('MMM d');
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(context.l10n.sellerOrderNo, style: _headerStyle(colors)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(context.l10n.sellerOrderDate, style: _headerStyle(colors)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(context.l10n.sellerCustomer, style: _headerStyle(colors)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(context.l10n.sellerStatus, style: _headerStyle(colors)),
                    ),
                  ],
                ),
              ),
              ...orders.asMap().entries.map((entry) {
                final index = entry.key;
                final order = entry.value;
                return _buildOrderRow(
                  context,
                  '#${order.orderNumber}',
                  order.createdAt == null ? '—' : dateFormat.format(order.createdAt!),
                  order.customerName ?? '—',
                  order.status,
                  showDivider: index != orders.length - 1,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  TextStyle _headerStyle(AppThemeColors colors) =>
      TextStyle(fontSize: 10, color: colors.textSecondary);

  Widget _buildOrderRow(
    BuildContext context,
    String no,
    String date,
    String customer,
    String status, {
    required bool showDivider,
  }) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.border))
            : null,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(no, style: _cellStyle(colors))),
          Expanded(flex: 3, child: Text(date, style: _cellStyle(colors))),
          Expanded(flex: 3, child: Text(customer, style: _cellStyle(colors))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel(status),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalyticsButton(
    BuildContext context,
    WidgetRef ref,
    String? userId,
  ) {
    final isLoading = _isAnalyticsLoading;
    return InkWell(
      onTap: isLoading
          ? null
          : () async {
              setState(() => _isAnalyticsLoading = true);
              try {
                if (userId != null && userId.isNotEmpty) {
                  await ref
                      .read(sellerAnalyticsControllerProvider.notifier)
                      .initialize(userId);
                }
                if (context.mounted) {
                  Navigator.of(context).pushNamed(AppRoutes.sellerAnalytics);
                }
              } finally {
                if (mounted) {
                  setState(() => _isAnalyticsLoading = false);
                }
              }
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111111), Color(0xFF2E2E2E)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111111).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.insights, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Analytics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Smart inventory & trend predictions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 16,
                  ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFF3095CE);
      case 'shipped':
        return const Color(0xFF2E7D32);
      case 'delivered':
        return const Color(0xFF70B673);
      case 'cancelled':
        return const Color(0xFFC95353);
      case 'pending':
      default:
        return context.appColors.textTertiary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  TextStyle _cellStyle(AppThemeColors colors) =>
      TextStyle(fontSize: 12, color: colors.textPrimary);
}
