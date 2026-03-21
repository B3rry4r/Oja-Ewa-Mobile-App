import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../account/subfeatures/your_address/domain/address.dart';
import '../../../orders/data/orders_repository_impl.dart';
import '../../../orders/domain/logistics_models.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';

/// Helper provider that maps the cart into the order create payload expected by POST /api/orders.
/// Uses optimisticCartProvider to stay in sync with cart screen and order confirmation.
final checkoutOrderItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  // Use optimistic cart for synced data across screens
  final cart = ref.watch(optimisticCartProvider);
  if (cart == null) return const [];

  return cart.items
      .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
      .toList();
});

final logisticsQuoteRequestProvider =
    Provider.family<LogisticsQuoteRequest?, Address?>((ref, address) {
      if (address == null) return null;

      final items = ref.watch(checkoutOrderItemsProvider);
      if (items.isEmpty) return null;

      return LogisticsQuoteRequest.fromAddress(items: items, address: address);
    });

final logisticsQuotesProvider = FutureProvider.autoDispose
    .family<List<SellerShippingQuotes>, LogisticsQuoteRequest>((
      ref,
      request,
    ) async {
      final token = ref.watch(accessTokenProvider);
      if (token == null || token.isEmpty) return const [];

      return ref.read(ordersRepositoryProvider).getShippingQuotes(request);
    });
