import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_clients.dart';
import '../domain/connect_info.dart';
import '../domain/connect_repository.dart';
import 'connect_api.dart';

class ConnectRepositoryImpl implements ConnectRepository {
  ConnectRepositoryImpl(this._api);

  final ConnectApi _api;

  @override
  Future<ConnectInfo> getConnectInfo() => _api.getConnectInfo();
}

final connectApiProvider = Provider<ConnectApi>((ref) {
  return ConnectApi(ref.watch(laravelDioProvider));
});

final connectRepositoryProvider = Provider<ConnectRepository>((ref) {
  return ConnectRepositoryImpl(ref.watch(connectApiProvider));
});
