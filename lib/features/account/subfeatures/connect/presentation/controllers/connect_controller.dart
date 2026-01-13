import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/connect_repository_impl.dart';
import '../../domain/connect_info.dart';

final connectInfoProvider = FutureProvider<ConnectInfo>((ref) async {
  return ref.watch(connectRepositoryProvider).getConnectInfo();
});
