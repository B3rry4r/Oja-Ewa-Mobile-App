import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cart_repository_impl.dart';
import '../../domain/cart.dart';

final cartProvider = FutureProvider<Cart>((ref) async {
  return ref.watch(cartRepositoryProvider).getCart();
});

class CartActionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> refresh() async {
    ref.invalidate(cartProvider);
  }

  Future<void> updateQuantity({required int cartItemId, required int quantity}) async {
    state = const AsyncLoading();
    try {
      await ref.read(cartRepositoryProvider).updateItemQuantity(cartItemId: cartItemId, quantity: quantity);
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> removeItem({required int cartItemId}) async {
    state = const AsyncLoading();
    try {
      await ref.read(cartRepositoryProvider).removeItem(cartItemId: cartItemId);
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> addItem({
    required int productId,
    required String selectedSize,
    String processingTimeType = 'normal',
    int quantity = 1,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(cartRepositoryProvider).addItem(
            productId: productId,
            quantity: quantity,
            selectedSize: selectedSize,
            processingTimeType: processingTimeType,
          );
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    state = const AsyncLoading();
    try {
      await ref.read(cartRepositoryProvider).clearCart();
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final cartActionsProvider = AsyncNotifierProvider<CartActionsController, void>(CartActionsController.new);
