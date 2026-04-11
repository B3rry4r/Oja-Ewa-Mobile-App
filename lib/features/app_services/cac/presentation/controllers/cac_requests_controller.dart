import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cac_services_api.dart';
import '../../domain/cac_registration_request.dart';

final cacRequestsProvider = FutureProvider<List<CacRegistrationRequest>>((
  ref,
) async {
  return ref.watch(cacServicesApiProvider).listRequests();
});
