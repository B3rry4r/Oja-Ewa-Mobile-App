import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/advert_placements_api.dart';
import '../../domain/advert_placement_request.dart';

final advertPlacementRequestsProvider =
    FutureProvider<List<AdvertPlacementRequest>>((ref) async {
      return ref.watch(advertPlacementsApiProvider).listRequests();
    });
