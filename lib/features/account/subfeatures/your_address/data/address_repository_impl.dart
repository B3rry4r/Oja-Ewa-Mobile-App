import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import '../domain/address.dart';
import '../domain/address_repository.dart';
import 'address_api.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._api);

  final AddressApi _api;

  @override
  Future<Address> createAddress(Address address) => _api.createAddress(address);

  @override
  Future<void> deleteAddress(int id) => _api.deleteAddress(id);

  @override
  Future<Address> getAddress(int id) => _api.getAddress(id);

  @override
  Future<List<Address>> getAddresses() => _api.getAddresses();

  @override
  Future<Address> updateAddress(Address address) => _api.updateAddress(address);
}

final addressApiProvider = Provider<AddressApi>((ref) {
  return AddressApi(ref.watch(laravelDioProvider));
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(ref.watch(addressApiProvider));
});
