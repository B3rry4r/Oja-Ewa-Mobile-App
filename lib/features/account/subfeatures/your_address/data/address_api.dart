import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';
import '../domain/address.dart';

class AddressApi {
  AddressApi(this._dio);

  final Dio _dio;

  Future<List<Address>> getAddresses() async {
    try {
      final res = await _dio.get('/api/addresses');
      return _extractList(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Address> getAddress(int id) async {
    try {
      final res = await _dio.get('/api/addresses/$id');
      return _extractOne(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Address> createAddress(Address address) async {
    try {
      final res = await _dio.post('/api/addresses', data: address.toJson());
      return _extractOne(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Address> updateAddress(Address address) async {
    try {
      final res = await _dio.put('/api/addresses/${address.id}', data: address.toJson());
      return _extractOne(res.data);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('/api/addresses/$id');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

List<Address> _extractList(dynamic data) {
  if (data is Map<String, dynamic>) {
    final list = data['data'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().map(Address.fromJson).toList();
    }
  }
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map(Address.fromJson).toList();
  }
  return const [];
}

Address _extractOne(dynamic data) {
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return Address.fromJson(inner);
    return Address.fromJson(data);
  }
  throw const FormatException('Unexpected address response');
}
