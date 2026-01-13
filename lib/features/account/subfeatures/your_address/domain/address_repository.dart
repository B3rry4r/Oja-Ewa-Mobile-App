import 'address.dart';

abstract interface class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<Address> getAddress(int id);
  Future<Address> createAddress(Address address);
  Future<Address> updateAddress(Address address);
  Future<void> deleteAddress(int id);
}
