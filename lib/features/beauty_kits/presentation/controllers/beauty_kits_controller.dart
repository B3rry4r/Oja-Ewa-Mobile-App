import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/beauty_kits_api.dart';
import '../../data/beauty_kits_repository.dart';
import '../../domain/beauty_kit.dart';

/// List of active beauty kits (guest-accessible — no auth gate).
final beautyKitsListProvider = FutureProvider<List<BeautyKit>>((ref) async {
  return ref.read(beautyKitsRepositoryProvider).listKits(perPage: 20);
});

/// Single kit detail keyed by id-or-slug (guest-accessible).
final beautyKitDetailProvider =
    FutureProvider.family<BeautyKit, String>((ref, idOrSlug) async {
  return ref.read(beautyKitsRepositoryProvider).getKit(idOrSlug);
});

/// Drives the "Buy all" / add-all-to-cart action and keeps the shared cart in
/// sync so the cart badge + cart screen reflect the new items.
class BeautyKitCartController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<BeautyKitAddToCartResult> addKitToCart(int kitId) async {
    state = const AsyncLoading();
    try {
      final result =
          await ref.read(beautyKitsRepositoryProvider).addKitToCart(kitId);
      // Reuse the existing cart sync path so the optimistic cart picks up the
      // server cart that now contains the kit's products.
      ref.read(optimisticCartProvider.notifier).requestSync();
      ref.invalidate(cartProvider);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final beautyKitCartControllerProvider =
    AsyncNotifierProvider<BeautyKitCartController, void>(
  BeautyKitCartController.new,
);
