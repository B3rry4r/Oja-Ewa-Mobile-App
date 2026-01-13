import 'package:dio/dio.dart';

import '../../../../../core/network/dio_error_mapper.dart';
import '../domain/connect_info.dart';

class ConnectApi {
  ConnectApi(this._dio);

  final Dio _dio;

  Future<ConnectInfo> getConnectInfo() async {
    try {
      final res = await _dio.get('/api/connect');
      final data = res.data;
      if (data is Map<String, dynamic>) return ConnectInfo.fromJson(data);
      throw const FormatException('Unexpected connect response');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
