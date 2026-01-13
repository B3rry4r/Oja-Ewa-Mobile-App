import 'connect_info.dart';

abstract interface class ConnectRepository {
  Future<ConnectInfo> getConnectInfo();
}
