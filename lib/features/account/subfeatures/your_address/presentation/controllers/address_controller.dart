import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/core/auth/auth_providers.dart';
import '../../data/address_repository_impl.dart';
import '../../domain/address.dart';

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return const [];
  
  return ref.read(addressRepositoryProvider).getAddresses();
});

final addressByIdProvider = FutureProvider.family<Address?, int>((ref, id) async {
  // Don't fetch if not authenticated
  final token = ref.watch(accessTokenProvider);
  if (token == null || token.isEmpty) return null;
  
  return ref.read(addressRepositoryProvider).getAddress(id);
});

class AddressActionsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns `true` on success, `false` if the operation failed.
  /// The error (if any) is captured in [state] for surfacing to the user.
  Future<bool> create(Address address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).createAddress(address);
      ref.invalidate(addressesProvider);
    });
    return !state.hasError;
  }

  /// Returns `true` on success, `false` if the operation failed.
  Future<bool> updateAddress(Address address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).updateAddress(address);
      ref.invalidate(addressesProvider);
    });
    return !state.hasError;
  }

  /// Returns `true` on success, `false` if the operation failed.
  Future<bool> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).deleteAddress(id);
      ref.invalidate(addressesProvider);
    });
    return !state.hasError;
  }
}

final addressActionsProvider = AsyncNotifierProvider<AddressActionsController, void>(
  AddressActionsController.new,
);
