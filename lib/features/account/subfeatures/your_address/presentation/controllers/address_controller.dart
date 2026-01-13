import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/address_repository_impl.dart';
import '../../domain/address.dart';

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  return ref.watch(addressRepositoryProvider).getAddresses();
});

final addressByIdProvider = FutureProvider.family<Address, int>((ref, id) async {
  return ref.watch(addressRepositoryProvider).getAddress(id);
});

class AddressActionsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(Address address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).createAddress(address);
      ref.invalidate(addressesProvider);
    });
  }

  Future<void> updateAddress(Address address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).updateAddress(address);
      ref.invalidate(addressesProvider);
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).deleteAddress(id);
      ref.invalidate(addressesProvider);
    });
  }
}

final addressActionsProvider = AsyncNotifierProvider<AddressActionsController, void>(
  AddressActionsController.new,
);
