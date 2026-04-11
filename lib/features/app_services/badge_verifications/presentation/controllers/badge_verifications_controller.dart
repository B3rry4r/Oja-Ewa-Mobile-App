import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/badge_verifications_api.dart';
import '../../domain/badge_option.dart';
import '../../domain/badge_verification_request.dart';

final badgeOptionsProvider = FutureProvider<List<BadgeOption>>((ref) async {
  return ref.watch(badgeVerificationsApiProvider).getOptions();
});

final badgeVerificationRequestsProvider =
    FutureProvider<List<BadgeVerificationRequest>>((ref) async {
      return ref.watch(badgeVerificationsApiProvider).listRequests();
    });
