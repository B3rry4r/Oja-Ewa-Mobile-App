import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/nepc_services_api.dart';
import '../../domain/nepc_registration_request.dart';

final nepcRequestsProvider = FutureProvider<List<NepcRegistrationRequest>>((
  ref,
) async {
  return ref.watch(nepcServicesApiProvider).listRequests();
});
