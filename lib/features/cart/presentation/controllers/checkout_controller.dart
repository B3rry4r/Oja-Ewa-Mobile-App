import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';

/// Helper provider that maps the cart into the order create payload expected by POST /api/orders.
/// Uses optimisticCartProvider to stay in sync with cart screen and order confirmation.
final checkoutOrderItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  // Use optimistic cart for synced data across screens
  final cart = ref.watch(optimisticCartProvider);
  if (cart == null) return const [];

  return cart.items
      .map(
        (i) => {
          'product_id': i.productId,
          'quantity': i.quantity,
        },
      )
      .toList();
});
