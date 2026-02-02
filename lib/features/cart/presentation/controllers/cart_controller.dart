import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import 'package:ojaewa/core/ui/snackbars.dart';
import '../../data/cart_repository_impl.dart';
import '../../domain/cart.dart';

final cartProvider = FutureProvider<Cart?>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return null;
  
  return ref.read(cartRepositoryProvider).getCart();
});

/// Holds the optimistic cart state - updated immediately on user actions,
/// synced with backend only on initial load or explicit refresh.
class OptimisticCartNotifier extends Notifier<Cart?> {
  bool _initialized = false;
  bool _pendingSync = false;

  @override
  Cart? build() {
    // Listen to the real cart provider for initial load AND when sync is requested
    ref.listen(cartProvider, (prev, next) {
      // Accept server data if:
      // 1. We haven't been initialized yet, OR
      // 2. A sync was explicitly requested (after add/clear operations)
      if (!_initialized || _pendingSync) {
        final data = next.asData?.value;
        if (data != null) {
          state = data;
          _initialized = true;
          _pendingSync = false;
        }
      }
    });
    // Initialize with current data if available
    final initialData = ref.read(cartProvider).asData?.value;
    if (initialData != null) {
      _initialized = true;
    }
    return initialData;
  }

  void setCart(Cart cart) {
    state = cart;
    _initialized = true;
  }

  /// Force sync from server - call this only when needed (e.g., after failure)
  void syncFromServer(Cart cart) {
    state = cart;
  }

  /// Mark that we want to sync from server on the next cartProvider update
  void requestSync() {
    _pendingSync = true;
  }

  /// Update a cart item's quantity optimistically
  void updateItemQuantity(int cartItemId, int newQuantity) {
    final current = state;
    if (current == null) return;

    final updatedItems = current.items.map((item) {
      if (item.id == cartItemId) {
        final newSubtotal = (item.unitPrice ?? 0) * newQuantity;
        return CartItem(
          id: item.id,
          productId: item.productId,
          quantity: newQuantity,
          unitPrice: item.unitPrice,
          subtotal: newSubtotal,
          selectedSize: item.selectedSize,
          processingTimeType: item.processingTimeType,
          product: item.product,
        );
      }
      return item;
    }).toList();

    // Recalculate total
    final newTotal = updatedItems.fold<num>(
      0,
      (sum, item) => sum + (item.subtotal ?? 0),
    );

    state = Cart(
      cartId: current.cartId,
      items: updatedItems,
      total: newTotal,
      itemsCount: updatedItems.length,
    );
  }

  /// Update a cart item's size optimistically
  void updateItemSize(int cartItemId, String newSize) {
    final current = state;
    if (current == null) return;

    final updatedItems = current.items.map((item) {
      if (item.id == cartItemId) {
        return CartItem(
          id: item.id,
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          subtotal: item.subtotal,
          selectedSize: newSize,
          processingTimeType: item.processingTimeType,
          product: item.product,
        );
      }
      return item;
    }).toList();

    state = Cart(
      cartId: current.cartId,
      items: updatedItems,
      total: current.total,
      itemsCount: current.itemsCount,
    );
  }

  /// Remove a cart item optimistically
  void removeItem(int cartItemId) {
    final current = state;
    if (current == null) return;

    final removedItem = current.items.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => current.items.first,
    );

    final updatedItems = current.items
        .where((item) => item.id != cartItemId)
        .toList();
    final newTotal = current.total - (removedItem.subtotal ?? 0);

    state = Cart(
      cartId: current.cartId,
      items: updatedItems,
      total: newTotal < 0 ? 0 : newTotal,
      itemsCount: updatedItems.length,
    );
  }
}

final optimisticCartProvider = NotifierProvider<OptimisticCartNotifier, Cart?>(
  OptimisticCartNotifier.new,
);

/// Controller for optimistic cart actions - updates UI immediately, syncs with backend,
/// and reverts on failure. Uses debouncing for quantity updates.
class OptimisticCartActionsController extends Notifier<void> {
  // Debounce timers per cart item for quantity updates
  final Map<int, Timer> _quantityDebounceTimers = {};
  // Track the last requested quantity per item for debounced backend calls
  final Map<int, int> _pendingQuantities = {};
  // Store rollback states per item
  final Map<int, Cart?> _rollbackStates = {};

  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  void build() {}

  Future<void> updateQuantity({
    required BuildContext context,
    required int cartItemId,
    required int newQuantity,
  }) async {
    // Save rollback state only if we don't have one for this item yet
    _rollbackStates[cartItemId] ??= ref.read(optimisticCartProvider);

    // Update optimistically immediately
    ref
        .read(optimisticCartProvider.notifier)
        .updateItemQuantity(cartItemId, newQuantity);

    // Store the pending quantity
    _pendingQuantities[cartItemId] = newQuantity;

    // Cancel existing timer for this item
    _quantityDebounceTimers[cartItemId]?.cancel();

    // Set up debounced backend call
    _quantityDebounceTimers[cartItemId] = Timer(_debounceDuration, () async {
      final quantityToSync = _pendingQuantities[cartItemId];
      if (quantityToSync == null) return;

      try {
        await ref
            .read(cartRepositoryProvider)
            .updateItemQuantity(
              cartItemId: cartItemId,
              quantity: quantityToSync,
            );
        // Clear rollback state on success - optimistic state is now the truth
        _rollbackStates.remove(cartItemId);
        _pendingQuantities.remove(cartItemId);
      } catch (e) {
        // Revert on failure
        final rollback = _rollbackStates.remove(cartItemId);
        if (rollback != null) {
          ref.read(optimisticCartProvider.notifier).setCart(rollback);
        }
        _pendingQuantities.remove(cartItemId);
        if (context.mounted) {
          AppSnackbars.showError(context, 'Failed to update quantity');
        }
      }
    });
  }

  Future<void> updateSize({
    required BuildContext context,
    required int cartItemId,
    required String newSize,
  }) async {
    // Save current state for rollback
    final previousCart = ref.read(optimisticCartProvider);

    // Update optimistically
    ref
        .read(optimisticCartProvider.notifier)
        .updateItemSize(cartItemId, newSize);

    try {
      await ref
          .read(cartRepositoryProvider)
          .updateItemSize(cartItemId: cartItemId, selectedSize: newSize);
      // Success - optimistic state is now the truth, no need to sync
    } catch (e) {
      // Revert on failure
      if (previousCart != null) {
        ref.read(optimisticCartProvider.notifier).setCart(previousCart);
      }
      if (context.mounted) {
        AppSnackbars.showError(context, 'Failed to update size');
      }
    }
  }

  Future<void> removeItem({
    required BuildContext context,
    required int cartItemId,
  }) async {
    // Save current state for rollback
    final previousCart = ref.read(optimisticCartProvider);

    // Update optimistically
    ref.read(optimisticCartProvider.notifier).removeItem(cartItemId);

    try {
      await ref.read(cartRepositoryProvider).removeItem(cartItemId: cartItemId);
      // Success - optimistic state is now the truth, no need to sync
    } catch (e) {
      // Revert on failure
      if (previousCart != null) {
        ref.read(optimisticCartProvider.notifier).setCart(previousCart);
      }
      if (context.mounted) {
        AppSnackbars.showError(context, 'Failed to remove item');
      }
    }
  }
}

final optimisticCartActionsProvider =
    NotifierProvider<OptimisticCartActionsController, void>(
      OptimisticCartActionsController.new,
    );

// Keep the old controller for backwards compatibility (add to cart, etc.)
class CartActionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> refresh() async {
    ref.invalidate(cartProvider);
  }

  Future<void> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(cartRepositoryProvider)
          .updateItemQuantity(cartItemId: cartItemId, quantity: quantity);
      ref.invalidate(cartProvider);
      ref.read(optimisticCartProvider.notifier).requestSync();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateSize({
    required int cartItemId,
    required String selectedSize,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(cartRepositoryProvider)
          .updateItemSize(cartItemId: cartItemId, selectedSize: selectedSize);
      ref.invalidate(cartProvider);
      ref.read(optimisticCartProvider.notifier).requestSync();
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
      ref.read(optimisticCartProvider.notifier).requestSync();
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
      await ref
          .read(cartRepositoryProvider)
          .addItem(
            productId: productId,
            quantity: quantity,
            selectedSize: selectedSize,
            processingTimeType: processingTimeType,
          );
      // Request sync so optimisticCartProvider picks up the new cart data
      ref.read(optimisticCartProvider.notifier).requestSync();
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
      // Request sync so optimisticCartProvider picks up the cleared cart
      ref.read(optimisticCartProvider.notifier).requestSync();
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final cartActionsProvider = AsyncNotifierProvider<CartActionsController, void>(
  CartActionsController.new,
);
