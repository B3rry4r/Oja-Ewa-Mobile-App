import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';

/// Helper provider that maps the cart into the order create payload expected by POST /api/orders.
final checkoutOrderItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final cartAsync = ref.watch(cartProvider);
  final cart = cartAsync.asData?.value;
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
